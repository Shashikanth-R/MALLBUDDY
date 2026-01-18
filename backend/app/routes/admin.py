from flask import Blueprint, request, jsonify
from app import db
from app.models import Store, Offer, Event, Mall, Category, ChatSession, ChatMessage
from datetime import datetime

bp = Blueprint('admin', __name__, url_prefix='/api/admin')


@bp.route('/dashboard/stats', methods=['GET'])
def get_dashboard_stats():
    """Get dashboard statistics"""
    total_malls = Mall.query.count()
    total_stores = Store.query.count()
    active_offers = Offer.query.filter_by(is_active=True).count()
    total_sessions = ChatSession.query.count()
    total_messages = ChatMessage.query.count()
    
    return jsonify({
        'total_malls': total_malls,
        'total_stores': total_stores,
        'active_offers': active_offers,
        'total_chat_sessions': total_sessions,
        'total_messages': total_messages
    }), 200


# ==================== STORES CRUD ====================

@bp.route('/stores', methods=['GET'])
def get_all_stores():
    """Get all stores for admin"""
    stores = Store.query.all()
    return jsonify({
        'stores': [store.to_dict() for store in stores],
        'count': len(stores)
    }), 200


@bp.route('/stores', methods=['POST'])
def create_store():
    """Create a new store"""
    data = request.get_json()
    
    # Validate required fields
    required_fields = ['name', 'mall_id', 'category_id', 'floor', 'unit']
    for field in required_fields:
        if field not in data:
            return jsonify({'error': f'{field} is required'}), 400
    
    try:
        store = Store(
            name=data['name'],
            mall_id=data['mall_id'],
            category_id=data['category_id'],
            floor=data['floor'],
            unit=data['unit'],
            description=data.get('description'),
            contact=data.get('contact'),
            status=data.get('status', 'open')
        )
        
        db.session.add(store)
        db.session.commit()
        
        return jsonify({
            'message': 'Store created successfully',
            'store': store.to_dict()
        }), 201
    
    except Exception as e:
        db.session.rollback()
        return jsonify({'error': str(e)}), 500


@bp.route('/stores/<int:store_id>', methods=['PUT'])
def update_store(store_id):
    """Update a store"""
    store = Store.query.get(store_id)
    
    if not store:
        return jsonify({'error': 'Store not found'}), 404
    
    data = request.get_json()
    
    try:
        # Update fields if provided
        if 'name' in data:
            store.name = data['name']
        if 'category_id' in data:
            store.category_id = data['category_id']
        if 'floor' in data:
            store.floor = data['floor']
        if 'unit' in data:
            store.unit = data['unit']
        if 'description' in data:
            store.description = data['description']
        if 'contact' in data:
            store.contact = data['contact']
        if 'status' in data:
            store.status = data['status']
        
        db.session.commit()
        
        return jsonify({
            'message': 'Store updated successfully',
            'store': store.to_dict()
        }), 200
    
    except Exception as e:
        db.session.rollback()
        return jsonify({'error': str(e)}), 500


@bp.route('/stores/<int:store_id>', methods=['DELETE'])
def delete_store(store_id):
    """Delete a store"""
    store = Store.query.get(store_id)
    
    if not store:
        return jsonify({'error': 'Store not found'}), 404
    
    try:
        db.session.delete(store)
        db.session.commit()
        
        return jsonify({'message': 'Store deleted successfully'}), 200
    
    except Exception as e:
        db.session.rollback()
        return jsonify({'error': str(e)}), 500


# ==================== OFFERS CRUD ====================

@bp.route('/offers', methods=['GET'])
def get_all_offers():
    """Get all offers for admin"""
    offers = Offer.query.all()
    return jsonify({
        'offers': [offer.to_dict() for offer in offers],
        'count': len(offers)
    }), 200


@bp.route('/offers', methods=['POST'])
def create_offer():
    """Create a new offer"""
    data = request.get_json()
    
    # Validate required fields
    required_fields = ['store_id', 'title', 'description', 'start_date', 'end_date']
    for field in required_fields:
        if field not in data:
            return jsonify({'error': f'{field} is required'}), 400
    
    try:
        offer = Offer(
            store_id=data['store_id'],
            title=data['title'],
            description=data['description'],
            start_date=datetime.fromisoformat(data['start_date']),
            end_date=datetime.fromisoformat(data['end_date']),
            is_featured=data.get('is_featured', False),
            is_active=data.get('is_active', True)
        )
        
        db.session.add(offer)
        db.session.commit()
        
        return jsonify({
            'message': 'Offer created successfully',
            'offer': offer.to_dict()
        }), 201
    
    except Exception as e:
        db.session.rollback()
        return jsonify({'error': str(e)}), 500


@bp.route('/offers/<int:offer_id>', methods=['PUT'])
def update_offer(offer_id):
    """Update an offer"""
    offer = Offer.query.get(offer_id)
    
    if not offer:
        return jsonify({'error': 'Offer not found'}), 404
    
    data = request.get_json()
    
    try:
        if 'title' in data:
            offer.title = data['title']
        if 'description' in data:
            offer.description = data['description']
        if 'start_date' in data:
            offer.start_date = datetime.fromisoformat(data['start_date'])
        if 'end_date' in data:
            offer.end_date = datetime.fromisoformat(data['end_date'])
        if 'is_featured' in data:
            offer.is_featured = data['is_featured']
        if 'is_active' in data:
            offer.is_active = data['is_active']
        
        db.session.commit()
        
        return jsonify({
            'message': 'Offer updated successfully',
            'offer': offer.to_dict()
        }), 200
    
    except Exception as e:
        db.session.rollback()
        return jsonify({'error': str(e)}), 500


@bp.route('/offers/<int:offer_id>', methods=['DELETE'])
def delete_offer(offer_id):
    """Delete an offer"""
    offer = Offer.query.get(offer_id)
    
    if not offer:
        return jsonify({'error': 'Offer not found'}), 404
    
    try:
        db.session.delete(offer)
        db.session.commit()
        
        return jsonify({'message': 'Offer deleted successfully'}), 200
    
    except Exception as e:
        db.session.rollback()
        return jsonify({'error': str(e)}), 500


# ==================== EVENTS CRUD ====================

@bp.route('/events', methods=['GET'])
def get_all_events():
    """Get all events for admin"""
    events = Event.query.all()
    return jsonify({
        'events': [event.to_dict() for event in events],
        'count': len(events)
    }), 200


@bp.route('/events', methods=['POST'])
def create_event():
    """Create a new event"""
    data = request.get_json()
    
    # Validate required fields
    required_fields = ['mall_id', 'name', 'description', 'event_date', 'location']
    for field in required_fields:
        if field not in data:
            return jsonify({'error': f'{field} is required'}), 400
    
    try:
        event = Event(
            mall_id=data['mall_id'],
            name=data['name'],
            description=data['description'],
            event_date=datetime.fromisoformat(data['event_date']),
            location=data['location']
        )
        
        db.session.add(event)
        db.session.commit()
        
        return jsonify({
            'message': 'Event created successfully',
            'event': event.to_dict()
        }), 201
    
    except Exception as e:
        db.session.rollback()
        return jsonify({'error': str(e)}), 500


@bp.route('/events/<int:event_id>', methods=['PUT'])
def update_event(event_id):
    """Update an event"""
    event = Event.query.get(event_id)
    
    if not event:
        return jsonify({'error': 'Event not found'}), 404
    
    data = request.get_json()
    
    try:
        if 'name' in data:
            event.name = data['name']
        if 'description' in data:
            event.description = data['description']
        if 'event_date' in data:
            event.event_date = datetime.fromisoformat(data['event_date'])
        if 'location' in data:
            event.location = data['location']
        
        db.session.commit()
        
        return jsonify({
            'message': 'Event updated successfully',
            'event': event.to_dict()
        }), 200
    
    except Exception as e:
        db.session.rollback()
        return jsonify({'error': str(e)}), 500


@bp.route('/events/<int:event_id>', methods=['DELETE'])
def delete_event(event_id):
    """Delete an event"""
    event = Event.query.get(event_id)
    
    if not event:
        return jsonify({'error': 'Event not found'}), 404
    
    try:
        db.session.delete(event)
        db.session.commit()
        
        return jsonify({'message': 'Event deleted successfully'}), 200
    
    except Exception as e:
        db.session.rollback()
        return jsonify({'error': str(e)}), 500

