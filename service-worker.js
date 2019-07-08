var responseContent =
    "<html>" +
    "<body>" +
    "<style>" +
    "body {text-align: center; background-color: #333; color: #eee;}" +
    "</style>" +
    "<h1>Çevrimdışı</h1>" +
    "<p>İnternet bağlantınızı kontrol ediniz.</p>" +
    "</body>" +
    "</html>";

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