# Python 3.14 compatibility fix
import sys
if sys.version_info >= (3, 14):
    # Workaround for metaclass issues in Python 3.14
    import warnings
    warnings.filterwarnings('ignore', category=DeprecationWarning)

from flask import Flask
from flask_sqlalchemy import SQLAlchemy
from flask_jwt_extended import JWTManager
from flask_cors import CORS
from flask_migrate import Migrate
from app.config import Config

# Initialize extensions
db = SQLAlchemy()
jwt = JWTManager()
migrate = Migrate()


def create_app(config_class=Config):
    """Application factory pattern"""
    app = Flask(__name__)
    app.config.from_object(config_class)

    # Initialize extensions
    db.init_app(app)
    jwt.init_app(app)
    migrate.init_app(app, db)
    
    # Configure CORS to allow all origins in development
    CORS(app, resources={
        r"/api/*": {
            "origins": "*",
            "methods": ["GET", "POST", "PUT", "DELETE", "OPTIONS"],
            "allow_headers": ["Content-Type", "Authorization"]
        }
    })

    # Register blueprints
    from app.routes import auth, chat, stores, offers, events, facilities, navigation
    # Temporarily disable analytics to fix startup
    # Temporarily disable analytics to fix startup
    from app.routes import admin_routes
    app.register_blueprint(chat.bp, url_prefix='/api/chat')
    app.register_blueprint(navigation.bp, url_prefix='/api/navigation')
    app.register_blueprint(admin_routes.bp)
    app.register_blueprint(auth.bp)
    app.register_blueprint(stores.bp)
    app.register_blueprint(offers.bp)
    app.register_blueprint(events.bp)
    app.register_blueprint(facilities.bp)
    # app.register_blueprint(analytics.bp)  # Temporarily disabled

    # Root endpoint - API documentation
    @app.route('/')
    def index():
        return {
            'service': 'MallBuddy API',
            'version': '1.0.0',
            'status': 'running',
            'endpoints': {
                'health': '/health',
                'auth': {
                    'register': 'POST /api/auth/register',
                    'login': 'POST /api/auth/login',
                    'profile': 'GET /api/auth/profile'
                },
                'stores': {
                    'list': 'GET /api/stores',
                    'get': 'GET /api/stores/<id>',
                    'search': 'GET /api/stores/search?q=<query>'
                },
                'offers': {
                    'list': 'GET /api/offers',
                    'featured': 'GET /api/offers/featured'
                },
                'events': {
                    'list': 'GET /api/events',
                    'upcoming': 'GET /api/events/upcoming'
                },
                'facilities': {
                    'list': 'GET /api/facilities',
                    'by_type': 'GET /api/facilities?type=<type>'
                },
                'navigation': {
                    'route': 'GET /api/navigation?from=<location>&to=<location>',
                    'map': 'GET /api/navigation/map/<mall_id>'
                },
                'chat': {
                    'send': 'POST /api/chat',
                    'history': 'GET /api/chat/history?session_id=<id>'
                },
                'admin': {
                    'stats': 'GET /api/admin/dashboard/stats'
                }
            },
            'documentation': 'Visit http://localhost:3000 for the frontend application'
        }, 200
    
    # Health check endpoint
    @app.route('/health')
    def health():
        return {'status': 'healthy', 'service': 'MallBuddy API'}, 200

    # Ensure database tables exist (Simple fix for Render/SQLite)
    with app.app_context():
        db.create_all()
        print("Database tables created/verified")
        
        # Seed default admin user if not exists
        try:
            from app.models import Admin
            from werkzeug.security import generate_password_hash
            
            admin_email = app.config.get('ADMIN_EMAIL', 'admin@mallbuddy.com')
            admin = Admin.query.filter_by(email=admin_email).first()
            
            if not admin:
                print(f"Creating default admin user: {admin_email}")
                admin_pass = app.config.get('ADMIN_PASSWORD', 'Admin@123')
                
                new_admin = Admin(
                    name='System Administrator',
                    email=admin_email,
                    password_hash=generate_password_hash(admin_pass),
                    role='super_admin',
                    is_active=True
                )
                db.session.add(new_admin)
                db.session.commit()
                print("✅ Default admin user created successfully")
            else:
                print("Admin user already exists")
        except Exception as e:
            print(f"❌ Failed to seed admin user: {e}")

    return app
