<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %>

<div class="container">
    <div class="page-header">
        <h1>${client.denomination}</h1>
        <div class="btn-group">
            <a href="${pageContext.request.contextPath}/clients/edit?id=${client.id}" class="btn btn-warning">
                <i class="fas fa-edit"></i> Modifier
            </a>
            <a href="${pageContext.request.contextPath}/clients/list" class="btn btn-secondary">
                <i class="fas fa-arrow-left"></i> Retour
            </a>
        </div>
    </div>
    
    <div class="row">
        <div class="col-md-8">
            <div class="card">
                <div class="card-header">
                    <h5>Informations du client</h5>
                </div>
                <div class="card-body">
                    <div class="detail-row">
                        <span class="detail-label">Dénomination:</span>
                        <span class="detail-value">${client.denomination}</span>
                    </div>
                    
                    <div class="detail-row">
                        <span class="detail-label">Sexe:</span>
                        <span class="detail-value">
                            <c:choose>
                                <c:when test="${not empty client.sexeId}">
                                    <c:set var="sexe" value="${sexeMap[client.sexeId]}" />
                                    ${not empty sexe ? sexe.libelle : 'Non spécifié'}
                                </c:when>
                                <c:otherwise>Non spécifié</c:otherwise>
                            </c:choose>
                        </span>
                    </div>
                    
                    <div class="detail-row">
                        <span class="detail-label">Type de client:</span>
                        <span class="detail-value">
                            <c:choose>
                                <c:when test="${not empty client.typeId}">
                                    <c:set var="typeClient" value="${typeClientMap[client.typeId]}" />
                                    ${not empty typeClient ? typeClient.libelle : 'Standard'}
                                </c:when>
                                <c:otherwise>Standard</c:otherwise>
                            </c:choose>
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
                        <span class="detail-label">ID:</span>
                        <span class="detail-value">#${client.id}</span>
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
