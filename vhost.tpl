server {
	listen 80;
	root /var/www/{{name}};
	index index.php index.html index.htm;
	server_name {{name}}.lc;

	location / {
	    try_files $uri $uri/ /index.php?$args;
	}
	
	#error_page 404 /var/www/{{name}}/404.html;
	#error_log /var/www/{{name}}/error.log;
	#access_log /var/www/{{name}}/access.log combined;

	location ~ \.php$ {
		fastcgi_split_path_info ^(.+\.php)(/.+)$;
		fastcgi_pass unix:/var/run/php5-fpm.sock;
		fastcgi_index index.php;
		include fastcgi_params;
	}
}