<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %>

<div class="container">
    <div class="page-header">
        <h1>Détails de la réservation #${reservation.id}</h1>
        <div class="btn-group">
            <a href="/reservations/${reservation.id}/edit" class="btn btn-warning">
                <i class="fas fa-edit"></i> Modifier
            </a>
            <a href="/reservations" class="btn btn-secondary">
                <i class="fas fa-arrow-left"></i> Retour
            </a>
        </div>
    </div>
    
    <div class="row">
        <div class="col-md-6">
            <div class="card mb-4">
                <div class="card-header">
                    <h5>Informations de la réservation</h5>
                </div>
                <div class="card-body">
                    <div class="detail-row">
                        <span class="detail-label">Nom du client:</span>
                        <span class="detail-value">${reservation.nom}</span>
                    </div>
                    
                    <div class="detail-row">
                        <span class="detail-label">Email:</span>
                        <span class="detail-value">${reservation.email}</span>
                    </div>
                    
                    <div class="detail-row">
                        <span class="detail-label">Date d'arrivée:</span>
                        <span class="detail-value">
                            <fmt:formatDate value="${reservation.dateArrivee}" pattern="dd/MM/yyyy"/>
                        </span>
                    </div>
                    
                    <div class="detail-row">
                        <span class="detail-label">Heure d'arrivée:</span>
                        <span class="detail-value">${reservation.heure}</span>
                    </div>
                    
                    <div class="detail-row">
                        <span class="detail-label">Nombre de personnes:</span>
                        <span class="detail-value">${reservation.nombrePersonnes}</span>
                    </div>
                    
                    <div class="detail-row">
                        <span class="detail-label">Statut:</span>
                        <span class="detail-value">
                            <span class="badge ${reservation.confirmed ? 'badge-success' : 'badge-warning'}">
                                ${reservation.confirmed ? 'Confirmée' : 'En attente'}
                            </span>
                        </span>
                    </div>
                </div>
            </div>
        </div>
        
        <div class="col-md-6">
            <div class="card mb-4">
                <div class="card-header">
                    <h5>Informations de l'hôtel</h5>
                </div>
                <div class="card-body">
                    <div class="detail-row">
                        <span class="detail-label">Nom:</span>
                        <span class="detail-value">${hotel.nom}</span>
                    </div>
                    
                    <div class="detail-row">
                        <span class="detail-label">Adresse:</span>
                        <span class="detail-value">${hotel.adresse}</span>
                    </div>
                    
                    <div class="detail-row">
                        <span class="detail-label">Ville:</span>
                        <span class="detail-value">${hotel.ville}, ${hotel.pays}</span>
                    </div>
                    
                    <div class="detail-row">
                        <span class="detail-label">Étoiles:</span>
                        <span class="detail-value">
                            <c:forEach begin="1" end="${hotel.nombreEtoiles}">⭐</c:forEach>
                        </span>
                    </div>
                </div>
            </div>
            
            <c:if test="${not empty client}">
                <div class="card">
                    <div class="card-header">
                        <h5>Informations du client</h5>
                    </div>
                    <div class="card-body">
                        <div class="detail-row">
                            <span class="detail-label">Dénomination:</span>
                            <span class="detail-value">${client.denomination}</span>
                        </div>
                        
                        <c:if test="${not empty sexe}">
                            <div class="detail-row">
                                <span class="detail-label">Sexe:</span>
                                <span class="detail-value">${sexe.libelle}</span>
                            </div>
                        </c:if>
                        
                        <c:if test="${not empty typeClient}">
                            <div class="detail-row">
                                <span class="detail-label">Type de client:</span>
                                <span class="detail-value">${typeClient.libelle}</span>
                            </div>
                        </c:if>
                    </div>
                </div>
            </c:if>
        </div>
    </div>
</div>
