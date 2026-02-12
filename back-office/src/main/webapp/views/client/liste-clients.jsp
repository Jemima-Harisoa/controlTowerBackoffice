<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>

<div class="container">
    <div class="page-header">
        <h1>Liste des clients</h1>
        <a href="${pageContext.request.contextPath}/clients/create" class="btn btn-primary">
            <i class="fas fa-plus"></i> Ajouter un client
        </a>
    </div>
    
    <c:if test="${not empty erreur}">
        <div class="alert alert-danger">
            <i class="fas fa-exclamation-triangle"></i> ${erreur}
        </div>
    </c:if>
    
    <c:if test="${not empty message}">
        <div class="alert alert-success">
            <i class="fas fa-check"></i> ${message}
        </div>
    </c:if>
    
    <div class="table-responsive">
        <table class="table table-striped table-hover">
            <thead class="thead-dark">
                <tr>
                    <th>ID</th>
                    <th>Dénomination</th>
                    <th>Sexe</th>
                    <th>Type</th>
                    <th>Actions</th>
                </tr>
            </thead>
            <tbody>
                <c:forEach items="${clients}" var="client">
                    <tr>
                        <td>${client.id}</td>
                        <td><strong>${client.denomination}</strong></td>
                        <td>
                            <c:choose>
                                <c:when test="${not empty client.sexeId}">
                                    <c:set var="sexe" value="${sexeMap[client.sexeId]}" />
                                    ${not empty sexe ? sexe.libelle : 'Non spécifié'}
                                </c:when>
                                <c:otherwise>Non spécifié</c:otherwise>
                            </c:choose>
                        </td>
                        <td>
                            <c:choose>
                                <c:when test="${not empty client.typeId}">
                                    <c:set var="typeClient" value="${typeClientMap[client.typeId]}" />
                                    ${not empty typeClient ? typeClient.libelle : 'Standard'}
                                </c:when>
                                <c:otherwise>Standard</c:otherwise>
                            </c:choose>
                        </td>
                        <td class="actions">
                            <a href="${pageContext.request.contextPath}/clients/view?id=${client.id}" 
                               class="btn btn-sm btn-info" title="Voir">
                                <i class="fas fa-eye"></i>
                            </a>
                            <a href="${pageContext.request.contextPath}/clients/edit?id=${client.id}" 
                               class="btn btn-sm btn-warning" title="Modifier">
                                <i class="fas fa-edit"></i>
                            </a>
                            <form action="${pageContext.request.contextPath}/clients/delete" 
                                  method="post" style="display: inline;">
                                <input type="hidden" name="id" value="${client.id}">
                                <button type="submit" class="btn btn-sm btn-danger" title="Supprimer" 
                                        onclick="return confirm('Êtes-vous sûr de vouloir supprimer ce client ?')">
                                    <i class="fas fa-trash"></i>
                                </button>
                            </form>
                        </td>
                    </tr>
                </c:forEach>
            </tbody>
        </table>
    </div>
    
    <c:if test="${empty clients}">
        <div class="empty-state text-center py-5">
            <i class="fas fa-users fa-3x mb-3 text-muted"></i>
            <h3>Aucun client trouvé</h3>
            <p>Commencez par ajouter votre premier client.</p>
            <a href="${pageContext.request.contextPath}/clients/create" class="btn btn-primary">
                <i class="fas fa-plus"></i> Ajouter un client
            </a>
        </div>
    </c:if>
</div>

<style>
.empty-state {
    text-align: center;
    padding: 2rem;
    color: #666;
}

.actions .btn {
    margin: 0 2px;
}
</style>
