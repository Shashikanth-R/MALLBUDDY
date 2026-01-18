const BACKEND_URL = 'http://localhost:5000';
let currentEditId = null;
let editMode = false;
let categories = [];
let stores = [];

// Check authentication
function checkAuth() {
    const token = localStorage.getItem('token');
    const userType = localStorage.getItem('userType');
    const user = JSON.parse(localStorage.getItem('user') || '{}');

    if (!token || userType !== 'admin') {
        window.location.href = 'login.html';
        return;
    }

    document.getElementById('adminName').textContent = user.name || 'Admin';
}

// Logout
function logout() {
    localStorage.clear();
    window.location.href = 'index.html';
}

// Switch tabs
function switchTab(tab) {
    document.querySelectorAll('.tab').forEach(t => t.classList.remove('active'));
    document.querySelectorAll('.tab-content').forEach(c => c.classList.remove('active'));

    event.target.classList.add('active');
    document.getElementById(`${tab}-tab`).classList.add('active');
}

// Load dashboard stats
async function loadStats() {
    try {
        const response = await fetch(`${BACKEND_URL}/api/admin/dashboard/stats`);
        const data = await response.json();

        document.getElementById('totalStores').textContent = data.total_stores || 0;
        document.getElementById('activeOffers').textContent = data.active_offers || 0;
        document.getElementById('totalEvents').textContent = data.total_chat_sessions || 0;
        document.getElementById('chatSessions').textContent = data.total_messages || 0;
    } catch (error) {
        console.error('Error loading stats:', error);
    }
}

// Load categories
async function loadCategories() {
    try {
        const response = await fetch(`${BACKEND_URL}/api/stores/categories`);
        const data = await response.json();
        categories = data.categories;

        const select = document.getElementById('storeCategory');
        select.innerHTML = '<option value="">Select Category</option>';
        categories.forEach(cat => {
            select.innerHTML += `<option value="${cat.id}">${cat.name}</option>`;
        });
    } catch (error) {
        console.error('Error loading categories:', error);
    }
}

// Load stores
async function loadStores() {
    try {
        const response = await fetch(`${BACKEND_URL}/api/admin/stores`);
        const data = await response.json();
        stores = data.stores;

        const tbody = document.querySelector('#storesTable tbody');
        tbody.innerHTML = '';

        stores.forEach(store => {
            tbody.innerHTML += `
                <tr>
                    <td>${store.name}</td>
                    <td>${store.category_name || 'N/A'}</td>
                    <td>${store.floor}</td>
                    <td>${store.unit}</td>
                    <td>${store.status}</td>
                    <td>
                        <button class="btn-edit" onclick="editStore(${store.id})">Edit</button>
                        <button class="btn-delete" onclick="deleteStore(${store.id})">Delete</button>
                    </td>
                </tr>
            `;
        });

        // Update store select in offer form
        const offerStoreSelect = document.getElementById('offerStore');
        offerStoreSelect.innerHTML = '<option value="">Select Store</option>';
        stores.forEach(store => {
            offerStoreSelect.innerHTML += `<option value="${store.id}">${store.name}</option>`;
        });
    } catch (error) {
        console.error('Error loading stores:', error);
    }
}

// Store Modal
function openStoreModal() {
    editMode = false;
    currentEditId = null;
    document.getElementById('storeModalTitle').textContent = 'Add Store';
    document.getElementById('storeForm').reset();
    document.getElementById('storeModal').style.display = 'block';
}

function closeStoreModal() {
    document.getElementById('storeModal').style.display = 'none';
}

function editStore(id) {
    const store = stores.find(s => s.id === id);
    if (!store) return;

    editMode = true;
    currentEditId = id;
    document.getElementById('storeModalTitle').textContent = 'Edit Store';
    document.getElementById('storeName').value = store.name;
    document.getElementById('storeCategory').value = store.category_id;
    document.getElementById('storeFloor').value = store.floor;
    document.getElementById('storeUnit').value = store.unit;
    document.getElementById('storeDescription').value = store.description || '';
    document.getElementById('storeModal').style.display = 'block';
}

async function deleteStore(id) {
    if (!confirm('Are you sure you want to delete this store?')) return;

    try {
        const response = await fetch(`${BACKEND_URL}/api/admin/stores/${id}`, {
            method: 'DELETE'
        });

        if (response.ok) {
            alert('Store deleted successfully!');
            loadStores();
            loadStats();
        } else {
            alert('Failed to delete store');
        }
    } catch (error) {
        console.error('Error deleting store:', error);
        alert('Error deleting store');
    }
}

document.getElementById('storeForm').addEventListener('submit', async (e) => {
    e.preventDefault();

    const storeData = {
        name: document.getElementById('storeName').value,
        category_id: parseInt(document.getElementById('storeCategory').value),
        floor: document.getElementById('storeFloor').value,
        unit: document.getElementById('storeUnit').value,
        description: document.getElementById('storeDescription').value,
        mall_id: 1
    };

    try {
        const url = editMode
            ? `${BACKEND_URL}/api/admin/stores/${currentEditId}`
            : `${BACKEND_URL}/api/admin/stores`;

        const response = await fetch(url, {
            method: editMode ? 'PUT' : 'POST',
            headers: { 'Content-Type': 'application/json' },
            body: JSON.stringify(storeData)
        });

        if (response.ok) {
            alert(editMode ? 'Store updated!' : 'Store created!');
            closeStoreModal();
            loadStores();
            loadStats();
        } else {
            const data = await response.json();
            alert(data.error || 'Operation failed');
        }
    } catch (error) {
        console.error('Error saving store:', error);
        alert('Error saving store');
    }
});

// Load offers
async function loadOffers() {
    try {
        const response = await fetch(`${BACKEND_URL}/api/admin/offers`);
        const data = await response.json();

        const tbody = document.querySelector('#offersTable tbody');
        tbody.innerHTML = '';

        data.offers.forEach(offer => {
            tbody.innerHTML += `
                <tr>
                    <td>${offer.title}</td>
                    <td>${offer.store_name || 'N/A'}</td>
                    <td>${new Date(offer.start_date).toLocaleDateString()}</td>
                    <td>${new Date(offer.end_date).toLocaleDateString()}</td>
                    <td>${offer.is_featured ? 'Yes' : 'No'}</td>
                    <td>
                        <button class="btn-edit" onclick="editOffer(${offer.id})">Edit</button>
                        <button class="btn-delete" onclick="deleteOffer(${offer.id})">Delete</button>
                    </td>
                </tr>
            `;
        });
    } catch (error) {
        console.error('Error loading offers:', error);
    }
}

// Offer Modal
function openOfferModal() {
    document.getElementById('offerModalTitle').textContent = 'Add Offer';
    document.getElementById('offerForm').reset();
    document.getElementById('offerModal').style.display = 'block';
}

function closeOfferModal() {
    document.getElementById('offerModal').style.display = 'none';
}

async function deleteOffer(id) {
    if (!confirm('Are you sure you want to delete this offer?')) return;

    try {
        const response = await fetch(`${BACKEND_URL}/api/admin/offers/${id}`, {
            method: 'DELETE'
        });

        if (response.ok) {
            alert('Offer deleted!');
            loadOffers();
            loadStats();
        }
    } catch (error) {
        console.error('Error deleting offer:', error);
    }
}

document.getElementById('offerForm').addEventListener('submit', async (e) => {
    e.preventDefault();

    const offerData = {
        store_id: parseInt(document.getElementById('offerStore').value),
        title: document.getElementById('offerTitle').value,
        description: document.getElementById('offerDescription').value,
        start_date: document.getElementById('offerStartDate').value,
        end_date: document.getElementById('offerEndDate').value
    };

    try {
        const response = await fetch(`${BACKEND_URL}/api/admin/offers`, {
            method: 'POST',
            headers: { 'Content-Type': 'application/json' },
            body: JSON.stringify(offerData)
        });

        if (response.ok) {
            alert('Offer created!');
            closeOfferModal();
            loadOffers();
            loadStats();
        }
    } catch (error) {
        console.error('Error creating offer:', error);
    }
});

// Load events
async function loadEvents() {
    try {
        const response = await fetch(`${BACKEND_URL}/api/admin/events`);
        const data = await response.json();

        const tbody = document.querySelector('#eventsTable tbody');
        tbody.innerHTML = '';

        data.events.forEach(event => {
            tbody.innerHTML += `
                <tr>
                    <td>${event.name}</td>
                    <td>${new Date(event.event_date).toLocaleString()}</td>
                    <td>${event.location}</td>
                    <td>
                        <button class="btn-delete" onclick="deleteEvent(${event.id})">Delete</button>
                    </td>
                </tr>
            `;
        });
    } catch (error) {
        console.error('Error loading events:', error);
    }
}

// Event Modal
function openEventModal() {
    document.getElementById('eventModalTitle').textContent = 'Add Event';
    document.getElementById('eventForm').reset();
    document.getElementById('eventModal').style.display = 'block';
}

function closeEventModal() {
    document.getElementById('eventModal').style.display = 'none';
}

async function deleteEvent(id) {
    if (!confirm('Are you sure you want to delete this event?')) return;

    try {
        const response = await fetch(`${BACKEND_URL}/api/admin/events/${id}`, {
            method: 'DELETE'
        });

        if (response.ok) {
            alert('Event deleted!');
            loadEvents();
        }
    } catch (error) {
        console.error('Error deleting event:', error);
    }
}

document.getElementById('eventForm').addEventListener('submit', async (e) => {
    e.preventDefault();

    const eventData = {
        mall_id: 1,
        name: document.getElementById('eventName').value,
        description: document.getElementById('eventDescription').value,
        event_date: document.getElementById('eventDate').value,
        location: document.getElementById('eventLocation').value
    };

    try {
        const response = await fetch(`${BACKEND_URL}/api/admin/events`, {
            method: 'POST',
            headers: { 'Content-Type': 'application/json' },
            body: JSON.stringify(eventData)
        });

        if (response.ok) {
            alert('Event created!');
            closeEventModal();
            loadEvents();
        }
    } catch (error) {
        console.error('Error creating event:', error);
    }
});

// Initialize
checkAuth();
loadStats();
loadCategories();
loadStores();
loadOffers();
loadEvents();
