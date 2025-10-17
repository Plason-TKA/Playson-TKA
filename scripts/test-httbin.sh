#!/bin/bash

DOMAIN="httpbin.playson-tka.int"

echo "Testing HTTPBin at: $DOMAIN"
echo "================================"

echo -n "GET /get -> "
curl -s -o /dev/null -w "%{http_code}\n" "http://$DOMAIN/get"

echo -n "GET /get?key=value -> "
curl -s -o /dev/null -w "%{http_code}\n" "http://$DOMAIN/get?key=value"

echo -n "GET /headers -> "
curl -s -o /dev/null -w "%{http_code}\n" "http://$DOMAIN/headers"

echo -n "GET /user-agent -> "
curl -s -o /dev/null -w "%{http_code}\n" "http://$DOMAIN/user-agent"

echo -n "GET /status/200 -> "
curl -s -o /dev/null -w "%{http_code}\n" "http://$DOMAIN/status/200"

echo -n "GET /status/201 -> "
curl -s -o /dev/null -w "%{http_code}\n" "http://$DOMAIN/status/201"

echo -n "GET /status/404 -> "
curl -s -o /dev/null -w "%{http_code}\n" "http://$DOMAIN/status/404"

echo -n "GET /status/500 -> "
curl -s -o /dev/null -w "%{http_code}\n" "http://$DOMAIN/status/500"

echo -n "GET /ip -> "
curl -s -o /dev/null -w "%{http_code}\n" "http://$DOMAIN/ip"

echo -n "GET /delay/2 -> "
curl -s -o /dev/null -w "%{http_code}\n" "http://$DOMAIN/delay/2"

echo -n "GET /uuid -> "
curl -s -o /dev/null -w "%{http_code}\n" "http://$DOMAIN/uuid"

echo -n "GET /base64/SFRUUEJpbg== -> "
curl -s -o /dev/null -w "%{http_code}\n" "http://$DOMAIN/base64/SFRUUEJpbg=="

echo -n "GET /html -> "
curl -s -o /dev/null -w "%{http_code}\n" "http://$DOMAIN/html"

echo -n "GET /json -> "
curl -s -o /dev/null -w "%{http_code}\n" "http://$DOMAIN/json"

echo -n "GET /robots.txt -> "
curl -s -o /dev/null -w "%{http_code}\n" "http://$DOMAIN/robots.txt"

echo -n "GET /cache -> "
curl -s -o /dev/null -w "%{http_code}\n" "http://$DOMAIN/cache"

echo -n "GET /response-headers?key=value -> "
curl -s -o /dev/null -w "%{http_code}\n" "http://$DOMAIN/response-headers?key=value"

echo "================================"
echo "Done!"