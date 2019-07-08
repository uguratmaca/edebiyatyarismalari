if ("serviceWorker" in navigator) {
    navigator.serviceWorker.register("/service-worker.js")
        .then(function (registration) {
            console.log("Service Worker registered with scope:",
                registration.scope);
        }).catch(function (err) {
            console.log("Service worker registration failed:", err);
        });
}