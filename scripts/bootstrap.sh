#!/bin/bash

sudo apt update
sudo apt install -y nginx

sudo systemctl enable nginx
sudo systemctl start nginx

echo "<html>
<head>
    <title>Status</title>
</head>
<body>
    <h1>Hello World</h1>
</body>
</html>" | sudo tee /var/www/html/index.html > /dev/null

sudo ufw allow 'Nginx HTTP'
sudo systemctl restart nginx
