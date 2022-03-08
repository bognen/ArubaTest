import java.io.*;
import javax.servlet.ServletException;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;

import org.json.JSONArray;
import com.fasterxml.jackson.core.JsonProcessingException;
import com.fasterxml.jackson.databind.ObjectMapper;
import org.json.JSONException;
import org.json.JSONObject;

import java.net.URI;
import java.net.http.HttpClient;
import java.net.http.HttpRequest;
import java.net.http.HttpResponse;
import java.time.LocalDateTime;
import java.util.*;
import java.util.concurrent.*;
import java.util.stream.Collectors;
import java.util.stream.IntStream;

public class Execute extends HttpServlet {
    private String uri = "";
    private String endPoint = "/configuration/full_wlan/";
    private String groupName = "";
    private Integer wlanNum = 3;
    private String accessToken = "";
    private String payload = "";

    /**
     * Standard Servlet. Used only for testing purposes
     */
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        PrintWriter out = response.getWriter();
        out.println ("GuestTek");
    }

    /**
     * Standard Servlet. Used to handle Create WLANs command sent from FrontEnd
     */
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        // Parse request
        uri = request.getParameter("uri");
        accessToken = request.getParameter("accessToken");
        groupName = request.getParameter("groupName")+"/";
        wlanNum = Integer.parseInt(request.getParameter("wlanNum"));
        payload = request.getParameter("value");

        Boolean isConcurrent = Boolean.parseBoolean(request.getParameter("isConcurrent"));

        JSONArray jsonArray;
        // Send POST requests
        if(isConcurrent) jsonArray = executeConcurrently();
        else jsonArray = executeSequentially();

        response.setContentType("application/json");
        response.getWriter().write(jsonArray.toString());
    }

    /**
     * Standard Servlet. Used to handle Delete WLANs command sent from FrontEnd
     */
    protected void doDelete(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        String wlanArrStr = request.getParameter("wlans");
        System.out.println(wlanArrStr);

        String[] wlanArr = wlanArrStr.split(",");
        JSONArray jsonArray = new JSONArray();
        for(int i=0; i<wlanArr.length; i++){
            JSONObject jo = sendCommand("", wlanArr[i], "DELETE");
            System.out.println(jo);
            jsonArray.put(jo);
        }

        response.setContentType("application/json");
        response.getWriter().write(jsonArray.toString());
    }

    /**
     * The method is used to send a single POST request to Aruba Central
     */
    private JSONObject sendCommand(String vlan, String ssidName, String method){
System.out.println(">>> Command - "+vlan+" - "+ ssidName);
        JSONObject json = new JSONObject();
        String localPayLoad = prepareRequestBody(payload, vlan, ssidName);

        try {
            Map values = new HashMap<String, String>() {{
                put ("value", localPayLoad);
            }};
            ObjectMapper objectMapper = new ObjectMapper();
            String requestBody = objectMapper.writeValueAsString(values);
            HttpClient client = HttpClient.newHttpClient();
            HttpRequest arubaRequest = HttpRequest.newBuilder()
                    .uri(URI.create(uri+endPoint+groupName+ssidName))
                    .header("Authorization","Bearer "+ accessToken)
                    .header("Content-Type", "application/json")
                    .method(method, HttpRequest.BodyPublishers.ofString(requestBody))
                    .build();
            HttpResponse<String> arubaResponse = client.send(arubaRequest, HttpResponse.BodyHandlers.ofString());
            Integer statusCode = arubaResponse.statusCode();

            try {
                json.put("date", LocalDateTime.now());
                json.put("thread", Thread.currentThread().getName());
                json.put("status", statusCode);
                json.put("response", arubaResponse.body());
            }
            catch (JSONException jse) {
                json.put("error", jse.getMessage());
            }
        }catch (JSONException jsex) {
            System.out.println("JSON exception was Caught");
            System.out.println("Error Message >> "+jsex.getMessage());
        }catch (InterruptedException | JsonProcessingException iex){
            System.out.println("Interrupted exception was Caught");
            System.out.println("Error Message >> "+iex.getMessage());
        } catch (IOException ioex){
            System.out.println("IOException exception was Caught");
            System.out.println("Error Message >> "+ioex.getMessage());
        }
        return json;
    }

    /**
     * Creates three WLANs concurrently
     */
    private JSONArray executeConcurrently(){
        System.out.println(">>> Creating Concurrently <<<");
        JSONArray jsonArray = new JSONArray();
        ExecutorService executorService =null;
        try {
            executorService = Executors.newFixedThreadPool(wlanNum);
            Collection<InnerArubaCall> callables = new ArrayList<>();
            IntStream.rangeClosed(1, wlanNum).forEach(i-> {
                String vlan = "145"+i;
                String ssid = "Canada"+i;
                callables.add(new InnerArubaCall(vlan, ssid));
            });

            // invoke all supplied Callables
            List<Future<JSONObject>> taskFutureList = executorService.invokeAll(callables);

            // Obtain result once it becomes available
            for (Future<JSONObject> future : taskFutureList) {
                jsonArray.put(future.get());
            }
        }catch (InterruptedException | ExecutionException iex){
            System.out.println("Interrupted exception was Caught");
            System.out.println("Error Message >> "+iex.getMessage());
        }finally{
            if(executorService != null) executorService.shutdown();
        }
        return jsonArray;
    }

    /**
     * Creates three WLANs sequentially
     */
    private JSONArray executeSequentially(){
        System.out.println(">>> Creating Sequentially <<<");
        JSONArray jsonArray = new JSONArray();
        for(int i=1; i<=wlanNum; i++){
            String vlan = "145"+i;
            String ssid = "Canada"+i;
            jsonArray.put(sendCommand(vlan, ssid, "POST"));
        }
        return jsonArray;
    }

    private String prepareRequestBody(String body, String vlan, String ssid){
        String resp = body;
        resp = resp.replaceAll("GTK_SSID_NAME", ssid);
        resp = resp.replaceAll("GTK_SSID_VLAN", vlan);
        return resp;
    }

    /**
     * Inner Class used to pass params to Callable
     */
    private class InnerArubaCall implements Callable<JSONObject> {
        private String vlan;
        private String ssidName;

        InnerArubaCall(String vlan, String ssidName){
            this.vlan = vlan;
            this.ssidName = ssidName;
        }

        public JSONObject call() {
            return sendCommand(vlan, ssidName, "POST");
        }
    }
}