// MallBuddy Frontend Configuration
// This file manages the backend API URL for different environments

(function () {
    // Detect environment and set appropriate backend URL
    const hostname = window.location.hostname;

    let backendUrl;

    if (hostname === 'localhost' || hostname === '127.0.0.1') {
        // Local development
        backendUrl = 'http://localhost:5000';
    } else if (hostname.includes('onrender.com')) {
        // Production on Render - Update this after deploying backend!
        // Replace 'mallbuddy-backend' with your actual Render backend service name
        backendUrl = 'https://mallbuddy-backend.onrender.com';
    } else {
        // Fallback - assume same origin or update for your custom domain
        backendUrl = 'https://mallbuddy-backend.onrender.com';
    }

    // Make BACKEND_URL globally available
    window.BACKEND_URL = backendUrl;

    console.log('MallBuddy Config loaded. Backend URL:', backendUrl);
})();
