# Create 
curl -X POST http://localhost:6767/shapes \
  -H "Content-Type: application/json" \
  -d '{
    "name": "Circle",
    "color": "Red",
    "side": 2
  }'

# Read todas
curl -X GET http://localhost:6767/shapes

#rEAD
curl -X GET http://localhost:6767/shapes/2

#update
curl -X PUT http://localhost:6767/shapes/2 \
  -H "Content-Type: application/json" \
  -d '{
    "name": "Updated Circle",
    "color": "Green",
    "sides": 4

  }'

# Delete s
curl -X DELETE http://localhost:6767/shapes/2

