var responseContent = `
<!DOCTYPE html>
<html lang="tr">
<head>
    <meta charset="utf-8">
</head>
<body>
    <style>
        body {
            text-align: center; 
            background-color: #333; 
            color: #eee;
            font-size: 2rem;
        }
    </style>
    
    <h1>Çevrimdışı</h1>
    <p>İnternet bağlantınızı kontrol ediniz.</p>
    </body>
</html>`;

self.addEventListener("fetch", function (event) {
    event.respondWith(
        fetch(event.request).catch(function () {
            return new Response(
                responseContent,
                { headers: { "Content-Type": "text/html" } }
            );
        })
    );
});