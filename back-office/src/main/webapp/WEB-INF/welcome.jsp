<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>

<style>
    .dashboard-grid {
        display: grid;
        grid-template-columns: repeat(auto-fit, minmax(250px, 1fr));
        gap: 20px;
        margin-bottom: 30px;
    }
    
    .stat-card {
        background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
        color: white;
        padding: 25px;
        border-radius: 10px;
        box-shadow: 0 4px 6px rgba(0,0,0,0.1);
    }
    
    .stat-card h3 {
        margin: 0 0 10px 0;
        font-size: 16px;
        opacity: 0.9;
    }
    
    .stat-card .stat-number {
        font-size: 36px;
        font-weight: bold;
        margin: 0;
    }
    
    .stat-card.hotels {
        background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
    }
    
    .stat-card.reservations {
        background: linear-gradient(135deg, #f093fb 0%, #f5576c 100%);
    }
    
    .stat-card.users {
        background: linear-gradient(135deg, #4facfe 0%, #00f2fe 100%);
    }
    
    .welcome-message {
        background: #f8f9fa;
        padding: 20px;
        border-radius: 8px;
        border-left: 4px solid #667eea;
        margin-bottom: 30px;
    }
    
    .welcome-message h2 {
        margin: 0 0 10px 0;
        color: #333;
    }
    
    .welcome-message p {
        margin: 0;
        color: #666;
    }
    
    .quick-actions {
        display: grid;
        grid-template-columns: repeat(auto-fit, minmax(200px, 1fr));
        gap: 15px;
        margin-top: 30px;
    }
    
    .action-btn {
        display: block;
        padding: 15px;
        background: white;
        border: 2px solid #e0e0e0;
        border-radius: 8px;
        text-decoration: none;
        color: #333;
        text-align: center;
        transition: all 0.3s;
    }
    
    .action-btn:hover {
        border-color: #667eea;
        color: #667eea;
        transform: translateY(-2px);
        box-shadow: 0 4px 8px rgba(0,0,0,0.1);
    }
    
    .action-btn .icon {
        font-size: 24px;
        margin-bottom: 10px;
    }
</style>

<div class="welcome-message">
    <h2>👋 Bienvenue sur Control Tower</h2>
    <p>Gérez vos hôtels, réservations et clients en toute simplicité</p>
</div>

<div class="dashboard-grid">
    <div class="stat-card hotels">
        <h3>🏨 Hôtels</h3>
        <p class="stat-number">${totalHotels}</p>
    </div>
    
    <div class="stat-card reservations">
        <h3>📅 Réservations</h3>
        <p class="stat-number">${totalReservations}</p>
    </div>
    
    <div class="stat-card users">
        <h3>👥 Utilisateurs</h3>
        <p class="stat-number">${totalUsers}</p>
    </div>
</div>

<h3>Actions Rapides</h3>
<div class="quick-actions">
    <a href="${pageContext.request.contextPath}/hotels/list" class="action-btn">
        <div class="icon">🏨</div>
        <div>Gérer les Hôtels</div>
    </a>
    
    <a href="${pageContext.request.contextPath}/reservations/create" class="action-btn">
        <div class="icon">➕</div>
        <div>Nouvelle Réservation</div>
    </a>
    
    <a href="${pageContext.request.contextPath}/clients/list" class="action-btn">
        <div class="icon">👥</div>
        <div>Voir les Clients</div>
    </a>
    
    <a href="${pageContext.request.contextPath}/reports/monthly" class="action-btn">
        <div class="icon">📊</div>
        <div>Rapports</div>
    </a>
</div>