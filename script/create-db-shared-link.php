<?php

$db_auth = file_get_contents('./db_token.var');

$parameters = array('path' => "/$argv[1]");

$headers = array("Authorization: Bearer $db_auth",
                 'Content-Type: application/json');

$curlOptions = array(
        CURLOPT_HTTPHEADER => $headers,
        CURLOPT_POST => true,
        CURLOPT_POSTFIELDS => json_encode($parameters),
        CURLOPT_RETURNTRANSFER => true,
        CURLOPT_VERBOSE => true
    );

$ch = curl_init('https://api.dropboxapi.com/2/sharing/create_shared_link_with_settings');
curl_setopt_array($ch, $curlOptions);

$response = curl_exec($ch);
echo $response;

curl_close($ch);

?>
