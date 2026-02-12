<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %>

<div class="container">
    <div class="page-header">
        <h1>${hotel.nom}</h1>
        <div class="btn-group">
            <a href="${pageContext.request.contextPath}/hotels/edit?id=${hotel.id}" class="btn btn-warning">
                <i class="fas fa-edit"></i> Modifier
            </a>
            <a href="${pageContext.request.contextPath}/hotels/list" class="btn btn-secondary">
                <i class="fas fa-arrow-left"></i> Retour
            </a>
        </div>
    </div>
    
    <div class="row">
        <div class="col-md-8">
            <div class="card">
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
                        <span class="detail-value">${hotel.ville}</span>
                    </div>
                    
                    <div class="detail-row">
                        <span class="detail-label">Pays:</span>
                        <span class="detail-value">${hotel.pays}</span>
                    </div>
                    
                    <div class="detail-row">
                        <span class="detail-label">Nombre d'étoiles:</span>
                        <span class="detail-value">
                            <c:forEach begin="1" end="${hotel.nombreEtoiles}">⭐</c:forEach>
                            (${hotel.nombreEtoiles}/5)
                        </span>
                    </div>
                    
                    <div class="detail-row">
                        <span class="detail-label">Description:</span>
                        <span class="detail-value">${hotel.description}</span>
                    </div>
                    
                    <div class="detail-row">
                        <span class="detail-label">Statut:</span>
                        <span class="detail-value">
                            <span class="badge ${hotel.active ? 'badge-success' : 'badge-danger'}">
                                ${hotel.active ? 'Actif' : 'Inactif'}
                            </span>
                        </span>
                    </div>
                </div>
            </div>
        </div>
        
        <div class="col-md-4">
            <div class="card">
                <div class="card-header">
                    <h5>Informations système</h5>
                </div>
                <div class="card-body">
                    <div class="detail-row">
                        <span class="detail-label">Créé le:</span>
                        <span class="detail-value">
                            <fmt:formatDate value="${hotel.createdAt}" pattern="dd/MM/yyyy HH:mm"/>
                        </span>
                    </div>
                    
                    <div class="detail-row">
                        <span class="detail-label">Mis à jour le:</span>
                        <span class="detail-value">
                            <fmt:formatDate value="${hotel.updatedAt}" pattern="dd/MM/yyyy HH:mm"/>
                        </span>
                    </div>
                    
                    <div class="detail-row">
                        <span class="detail-label">ID:</span>
                        <span class="detail-value">#${hotel.id}</span>
                    </div>
                </div>
            </div>
        </div>
    </div>
</div>

<style>
.detail-row {
    display: flex;
    justify-content: space-between;
    padding: 0.5rem 0;
    border-bottom: 1px solid #eee;
}

.detail-row:last-child {
    border-bottom: none;
}

.detail-label {
    font-weight: bold;
    color: #666;
}

.detail-value {
    text-align: right;
    color: #333;
}

.page-header {
    display: flex;
    justify-content: space-between;
    align-items: center;
    margin-bottom: 2rem;
    padding-bottom: 1rem;
    border-bottom: 1px solid #eee;
}
</style>
