<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>

<div class="container">
    <h1>Modifier le client #${client.id}</h1>
    
    <c:if test="${not empty erreurs}">
        <div class="alert alert-danger">
            <ul>
                <c:forEach items="${erreurs}" var="erreur">
                    <li>${erreur}</li>
                </c:forEach>
            </ul>
        </div>
    </c:if>
    
    <c:if test="${not empty erreur}">
        <div class="alert alert-danger">
            <i class="fas fa-exclamation-triangle"></i> ${erreur}
        </div>
    </c:if>
    
    <form action="${pageContext.request.contextPath}/clients/edit" method="post">
        <input type="hidden" name="id" value="${client.id}">
        
        <div class="form-group">
            <label for="denomination">Dénomination *</label>
            <input type="text" id="denomination" name="denomination" class="form-control" 
                   value="${client.denomination}" required>
            <small class="form-text text-muted">Nom du client ou raison sociale</small>
        </div>
        
        <div class="row">
            <div class="col-md-6">
                <div class="form-group">
                    <label for="sexeId">Sexe</label>
                    <select id="sexeId" name="sexeId" class="form-control">
                        <option value="">Non spécifié</option>
                        <c:forEach items="${sexes}" var="sexe">
                            <option value="${sexe.id}" ${client.sexeId == sexe.id ? 'selected' : ''}>
                                ${sexe.libelle}
                            </option>
                        </c:forEach>
                    </select>
                </div>
            </div>
            
            <div class="col-md-6">
                <div class="form-group">
                    <label for="typeId">Type de client</label>
                    <select id="typeId" name="typeId" class="form-control">
                        <option value="">Standard</option>
                        <c:forEach items="${typeClients}" var="typeClient">
                            <option value="${typeClient.id}" ${client.typeId == typeClient.id ? 'selected' : ''}>
                                ${typeClient.libelle}
                            </option>
                        </c:forEach>
                    </select>
                </div>
            </div>
        </div>
        
        <div class="form-actions">
            <button type="submit" class="btn btn-primary">
                <i class="fas fa-save"></i> Mettre à jour le client
            </button>
            <a href="${pageContext.request.contextPath}/clients/list" class="btn btn-secondary">
                <i class="fas fa-times"></i> Annuler
            </a>
        </div>
    </form>
</div>

<style>
.form-actions {
    margin-top: 2rem;
    padding-top: 1rem;
    border-top: 1px solid #eee;
}

.form-actions .btn {
    margin-right: 0.5rem;
}
</style>
