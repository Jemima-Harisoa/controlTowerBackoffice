<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%-- Liste des réservations : inclut header (sidebar+layout) et footer automatiquement --%>
<%@ include file="/views/components/header.jsp" %>

<style>
    .reservations-header {
        display: flex;
        justify-content: space-between;
        align-items: center;
        margin-bottom: 25px;
    }
    
    .reservations-header h2 {
        margin: 0;
        color: #333;
        font-size: 28px;
    }
    
    .btn-primary {
        padding: 12px 24px;
        background: #007bff;
        color: white;
        text-decoration: none;
        border-radius: 6px;
        transition: all 0.3s;
        font-weight: 500;
        box-shadow: 0 2px 4px rgba(0,123,255,0.3);
    }
    
    .btn-primary:hover {
        background: #0056b3;
        transform: translateY(-2px);
        box-shadow: 0 4px 8px rgba(0,123,255,0.4);
    }
    
    .reservations-table {
        width: 100%;
        border-collapse: collapse;
        background: white;
        border-radius: 8px;
        overflow: hidden;
        box-shadow: 0 2px 8px rgba(0,0,0,0.08);
    }
    
    .reservations-table thead {
        background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
    }
    
    .reservations-table th {
        padding: 16px;
        text-align: left;
        color: white;
        font-weight: 600;
        font-size: 14px;
        text-transform: uppercase;
        letter-spacing: 0.5px;
    }
    
    .reservations-table tbody tr {
        border-bottom: 1px solid #f0f0f0;
        transition: all 0.3s;
    }
    
    .reservations-table tbody tr:hover {
        background-color: #f8f9fa;
        transform: scale(1.01);
        box-shadow: 0 2px 4px rgba(0,0,0,0.05);
    }
    
    .reservations-table td {
        padding: 14px 16px;
        color: #555;
        font-size: 14px;
    }
    
    .badge {
        padding: 6px 12px;
        border-radius: 20px;
        font-size: 12px;
        font-weight: 600;
        text-transform: uppercase;
        letter-spacing: 0.5px;
    }
    
    .badge-success {
        background: #d4edda;
        color: #155724;
    }
    
    .badge-warning {
        background: #fff3cd;
        color: #856404;
    }
    
    .actions {
        display: flex;
        gap: 8px;
    }
    
    .btn-sm {
        padding: 6px 12px;
        border-radius: 4px;
        text-decoration: none;
        font-size: 13px;
        transition: all 0.3s;
        font-weight: 500;
    }
    
    .btn-info {
        background: #17a2b8;
        color: white;
    }
    
    .btn-info:hover {
        background: #138496;
    }
    
    .btn-warning {
        background: #ffc107;
        color: #333;
    }
    
    .btn-warning:hover {
        background: #e0a800;
    }
    
    .btn-danger {
        background: #dc3545;
        color: white;
        border: none;
        cursor: pointer;
    }
    
    .btn-danger:hover {
        background: #c82333;
    }
    
    .empty-state {
        text-align: center;
        padding: 60px 20px;
        color: #999;
    }
    
    .empty-state i {
        font-size: 64px;
        margin-bottom: 20px;
        opacity: 0.3;
    }
    
    .empty-state h3 {
        margin: 0 0 10px;
        color: #666;
    }
    
    .empty-state p {
        margin: 0;
    }
    
    .stats-cards {
        display: grid;
        grid-template-columns: repeat(auto-fit, minmax(200px, 1fr));
        gap: 20px;
        margin-bottom: 30px;
    }
    
    .stat-card {
        background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
        padding: 20px;
        border-radius: 10px;
        color: white;
        box-shadow: 0 4px 6px rgba(0,0,0,0.1);
    }
    
    .stat-card h3 {
        margin: 0 0 10px;
        font-size: 32px;
        font-weight: 700;
    }
    
    .stat-card p {
        margin: 0;
        opacity: 0.9;
        font-size: 14px;
    }

    .stat-card-confirmed {
        background: linear-gradient(135deg, #f093fb 0%, #f5576c 100%);
    }

    .stat-card-pending {
        background: linear-gradient(135deg, #4facfe 0%, #00f2fe 100%);
    }

    .alert {
        padding: 12px 20px;
        border-radius: 6px;
        margin-bottom: 20px;
    }

    .alert-success {
        background: #d4edda;
        color: #155724;
    }

    .alert-danger {
        background: #f8d7da;
        color: #721c24;
    }

    .empty-state-icon {
        font-size: 64px;
        margin-bottom: 20px;
        opacity: 0.3;
    }

    .text-muted-sm {
        color: #999;
        font-size: 12px;
    }

    .inline-form {
        display: inline;
    }
</style>

<!-- Statistiques -->
<c:if test="${not empty reservations}">
    <div class="stats-cards">
        <div class="stat-card">
            <h3>${reservations.size()}</h3>
            <p>Réservations totales</p>
        </div>
        <div class="stat-card stat-card-confirmed">
            <h3>
                <c:set var="confirmed" value="0"/>
                <c:forEach items="${reservations}" var="res">
                    <c:if test="${res.confirmed}">
                        <c:set var="confirmed" value="${confirmed + 1}"/>
                    </c:if>
                </c:forEach>
                ${confirmed}
            </h3>
            <p>Confirmées</p>
        </div>
        <div class="stat-card stat-card-pending">
            <h3>${reservations.size() - confirmed}</h3>
            <p>En attente</p>
        </div>
    </div>
</c:if>

<!-- En-tête avec bouton -->
<div class="reservations-header">
    <h2><i class="fas fa-calendar-alt"></i> Mes Reservations</h2>
    <a href="${pageContext.request.contextPath}/reservations/create" class="btn-primary">
        <i class="fas fa-plus"></i> Nouvelle Reservation
    </a>
</div>

<!-- Messages -->
<c:if test="${not empty message}">
    <div class="alert alert-success">
        ${message}
    </div>
</c:if>

<c:if test="${not empty erreur}">
    <div class="alert alert-danger">
        ${erreur}
    </div>
</c:if>

<!-- Tableau des réservations -->
<c:choose>
    <c:when test="${empty reservations}">
        <div class="empty-state">
            <div class="empty-state-icon"><i class="fas fa-clipboard-list"></i></div>
            <h3>Aucune réservation</h3>
            <p>Commencez par créer votre première réservation</p>
            <br>
            <a href="${pageContext.request.contextPath}/reservations/create" class="btn-primary">
                Créer une réservation
            </a>
        </div>
    </c:when>
    <c:otherwise>
        <table class="reservations-table">
            <thead>
                <tr>
                    <th>ID</th>
                    <th>Client</th>
                    <th>Email</th>
                    <th>Date d'arrivée</th>
                    <th>Heure</th>
                    <th>Personnes</th>
                    <th>Hôtel</th>
                    <th>Statut</th>
                    <th>Actions</th>
                </tr>
            </thead>
            <tbody>
                <c:forEach items="${reservations}" var="reservation">
                    <tr>
                        <td><strong>#${reservation.id}</strong></td>
                        <td>${reservation.nomFormate}</td>
                        <td>${reservation.email}</td>
                        <td>${reservation.dateAffichee}</td>
                        <td>${reservation.heureAffichee}</td>
                        <td>
                            <strong>${reservation.nombrePersonnes}</strong>
                            <span class="text-muted-sm">pers.</span>
                        </td>
                        <td>${reservation.nomHotel}</td>
                        <td>
                            <c:choose>
                                <c:when test="${reservation.confirmed}">
                                    <span class="badge badge-success"><i class="fas fa-check"></i> Confirmee</span>
                                </c:when>
                                <c:otherwise>
                                    <span class="badge badge-warning"><i class="fas fa-hourglass-half"></i> En attente</span>
                                </c:otherwise>
                            </c:choose>
                        </td>
                        <td>
                            <div class="actions">
                                <a href="${pageContext.request.contextPath}/reservations/${reservation.id}" 
                                   class="btn-sm btn-info" title="Voir détails">
                                    <i class="fas fa-eye"></i> Voir
                                </a>
                                <a href="${pageContext.request.contextPath}/reservations/${reservation.id}/edit" 
                                   class="btn-sm btn-warning" title="Modifier">
                                    <i class="fas fa-edit"></i> Modifier
                                </a>
                                <form action="${pageContext.request.contextPath}/reservations/${reservation.id}/delete" 
                                      method="post" 
                                      class="inline-form"
                                      onsubmit="return confirm('Êtes-vous sûr de vouloir supprimer cette réservation ?');">
                                    <button type="submit" class="btn-sm btn-danger" title="Supprimer">
                                        <i class="fas fa-trash-alt"></i> Supprimer
                                    </button>
                                </form>
                            </div>
                        </td>
                    </tr>
                </c:forEach>
            </tbody>
        </table>
    </c:otherwise>
</c:choose>

<%-- Footer commun : ferme le layout et charge les scripts --%>
<%@ include file="/views/components/footer.jsp" %>
