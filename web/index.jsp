<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<html>
  <head>
    <link rel="stylesheet" href="https://maxcdn.bootstrapcdn.com/bootstrap/4.0.0/css/bootstrap.min.css" integrity="sha384-Gn5384xqQ1aoWXA+058RXPxPg6fy4IWvTNh0E263XmFcJlSAwiGgFAW/dAiS6JXm" crossorigin="anonymous">
    <script type="text/javascript" src="http://ajax.googleapis.com/ajax/libs/jquery/1.4/jquery.min.js"></script>
    <script src="jquery.blockUI.js"></script>
    <script type="text/javascript">
      $(document).ready(function() {
        $('#call').click(function () {
          $.blockUI({ message: '<div class="loader"></div>',
              css: {
                  backgroundColor: 'transparent',
                  color: '#fff',
                  opacity: 0.6,
                  border: 'none'
          } });
          $.ajax({
                url: window.location.origin+"/ArubaTest/Execute",
                type: 'POST',
                dataType : 'json', // data type
                data: {
                    uri: $('#uri').val(),
                    accessToken: $('#accToken').val(),
                    groupName: $('#groupName').val(),
                    wlanNum: $('#wlanNum').val(),
                    isConcurrent: $('#isConcurrent').is(":checked"),
                    value: $('#value').val()
                },
                success: function(msg){
                    //alert("success");
                    $('#output').html('');
                    $('#created').html('');
                    let respArr = JSON.parse(JSON.stringify(msg));
                    respArr.forEach( (r, ind, arr) => {
                        let line = r.date + " - " + r.thread + " - " + r.status + " - " + r.response;
                        $('#output').append(line);
                        if(r.status == '200'){
                            let createdWlan = r.response.replace('"','')
                            if (ind === (arr.length -1)) createdWlan = createdWlan.replace('"','')
                            else createdWlan = createdWlan.replace('"',',')
                            $('#created').append(createdWlan);
                        }
                    })
                    $.unblockUI();
                },
                error: function(msg){
                    $('#output').append(JSON.stringify(msg));
                    $.unblockUI();
              }
          });
        });

          $('#remove').click(function () {
              $.blockUI({ message: '<div class="loader"></div>',
                  css: {
                      backgroundColor: 'transparent',
                      color: '#fff',
                      opacity: 0.6,
                      border: 'none'
              } });
              let cr = $('#created').val();
              console.log(cr);

              $.ajax({
                  url: window.location.origin+"/ArubaTest/Execute?wlans="+cr,
                  type: 'DELETE',
                  success: function(msg){
                      $.unblockUI();
                      let respArr = JSON.stringify(msg);
                      $('#output').html('');
                      $('#created').html('');
                      console.log("Response > ", respArr);
                      $('#output').append(respArr)
                  },
                  error: function(msg){
                      $.unblockUI();
                      alert("Error Occurred");
                      $('#output').val('');
                      $('#created').val('');
                      console.log("Error > ", msg);
                  }
              });
          });

      });
    </script>
    <meta http-equiv="Content-Type" content="text/html; charset=UTF-8">
    <style>
          .loader {
              border: 16px solid #f3f3f3;
              border-radius: 50%;
              border-top: 16px solid #3498db;
              width: 120px;
              height: 120px;
              animation: spin 2s linear infinite;
              display: inline-block;
          }
          /* Safari */
          @-webkit-keyframes spin {
              0% { -webkit-transform: rotate(0deg); }
              100% { -webkit-transform: rotate(360deg); }
          }

          @keyframes spin {
              0% { transform: rotate(0deg); }
              100% { transform: rotate(360deg); }
          }
      </style>
    <title>JSP APP</title>
  </head>
  <body>
      <div class="container mt-3 pt-4 pb-4" style="background-color: #e6e9eb; width: 65%;!important">
              <form id="form" action="" method="post">
                  <div class="form-group">
                      <div class="row">
                          <div class="col-sm-6">
                              <label for="uri">URL:</label>
                              <input type="text" class="form-control" id="uri" value="https://apigw-ca.central.arubanetworks.com">
                          </div>
                          <div class="col-sm-6">
                              <label for="accToken">Access Token:</label>
                              <input type="text" class="form-control" id="accToken" value="pr0v15eAcc3ssT0k3n">
                          </div>
                      </div>
                  </div>

                  <div class="form-group">
                      <div class="row">
                          <div class="col-sm-6">
                              <label for="groupName">Group Name:</label>
                              <input type="text" class="form-control" id="groupName" value="RDV-HOTEL-DIMA">
                          </div>
                          <div class="col-sm-6">
                              <label for="wlanNum">Number of WLANs:</label>
                              <input type="number" class="form-control" value="3" id="wlanNum" min="1" max="5">
                          </div>
                      </div>
                  </div>
                  <div class="form-group">
                      <div class="form-check">
                          <input type="checkbox" class="form-check-input" id="isConcurrent" checked>
                          <label class="form-check-label" for="isConcurrent">Create Concurrently</label>
                      </div>
                  </div>
                  <div class="form-group">
                      <label for="groupName">VALUE:</label>
                      <textarea class="form-control" id="value" rows="6">
{"wlan": {"a_max_tx_rate": "54", "a_min_tx_rate": "12", "access_type": "unrestricted", "air_time_limit_cb": false, "auth_cache_timeout": 24, "auth_server1": "", "auth_survivability": false, "bandwidth_limit_cb": false, "blacklist": true, "broadcast_filter": "arp", "called_station_id_type": "macaddr", "captive_portal": "disable", "deny_intra_vlan_traffic": false, "disable_ssid": false, "dmo_channel_util_threshold": 90, "dot11k": false, "dot11r": false, "dot11v": false, "download_role": false, "dtim_period": 1, "dynamic_multicast_optimization": false, "dynamic_vlans": [], "essid": "GTK_SSID_NAME", "g_max_tx_rate": "54", "g_min_tx_rate": "12", "hide_ssid": false, "high_efficiency_disable": true, "high_throughput_disable": true, "inactivity_timeout": 1000, "mac_authentication": false, "max_clients_threshold": 64, "mdid": "", "multicast_rate_optimization": false, "name": "GTK_SSID_NAME", "okc": false, "opmode": "opensystem",  "opmode_transition_disable": true, "per_user_limit_cb": false, "rf_band": "all", "roles": [], "set_role_machine_auth_machine_only": "", "ssid_encoding": "utf8 ","type": "employee", "user_bridging": true, "very_high_throughput_disable": true, "vlan": "GTK_SSID_VLAN","wep_index": 0, "wep_key": "", "advertise_ap_name": true, "wpa_passphrase": "", "zone":"Lobby,Pool"}, "access_rule": {"name": "GTK_SSID_NAME", "action": "allow" } }
                      </textarea>
                  </div>
              </form>
              <div class="row">
                  <div class="col-sm-10">
                      <fieldset>
                          <legend>Response:</legend>
                          <textarea class="form-control" id="output" rows="6"></textarea>
                      </fieldset>
                  </div>
                  <div class="col-sm-2">
                      <fieldset>
                          <legend>Created:</legend>
                          <textarea class="form-control" id="created" rows="6"></textarea>
                      </fieldset>
                  </div>
              </div>

          <div class="row mt-3">
              <div class="col-sm-10">
                  <button type="submit" class="btn btn-primary" id="call">Create WLANs</button>
              </div>
              <div class="col-sm-2">
                  <button type="submit" class="btn btn-primary" id="remove">Remove</button>
              </div>
          </div>
      </div>
        <a href="" target="_blank"><h3>SOURCE CODE</h3></a>
  </body>
</html>
<!-- https://jquery.malsup.com/block/ -->