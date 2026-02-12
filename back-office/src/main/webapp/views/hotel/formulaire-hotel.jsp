<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>

<div class="container">
    <h1>Ajouter un hôtel</h1>
    
    <c:if test="${not empty erreur}">
        <div class="alert alert-danger">
            <i class="fas fa-exclamation-triangle"></i> ${erreur}
        </div>
    </c:if>
    
    <form action="${pageContext.request.contextPath}/hotels/create" method="post">
        <div class="row">
            <div class="col-md-6">
                <div class="form-group">
                    <label for="nom">Nom de l'hôtel *</label>
                    <input type="text" id="nom" name="nom" class="form-control" 
                           value="${param.nom}" required>
                </div>
            </div>
            
            <div class="col-md-6">
                <div class="form-group">
                    <label for="etoiles">Nombre d'étoiles (1-5) *</label>
                    <input type="number" id="etoiles" name="etoiles" min="1" max="5" 
                           class="form-control" value="${param.etoiles}" required>
                </div>
            </div>
        </div>
        
        <div class="row">
            <div class="col-md-6">
                <div class="form-group">
                    <label for="adresse">Adresse *</label>
                    <input type="text" id="adresse" name="adresse" class="form-control" 
                           value="${param.adresse}" required>
                </div>
            </div>
            
            <div class="col-md-6">
                <div class="form-group">
                    <label for="ville">Ville *</label>
                    <input type="text" id="ville" name="ville" class="form-control" 
                           value="${param.ville}" required>
                </div>
            </div>
        </div>
        
        <div class="form-group">
            <label for="pays">Pays *</label>
            <input type="text" id="pays" name="pays" class="form-control" 
                   value="${param.pays}" required>
        </div>
        
        <div class="form-group">
            <label for="description">Description</label>
            <textarea id="description" name="description" class="form-control" 
                      rows="4" placeholder="Description de l'hôtel...">${param.description}</textarea>
        </div>
        
        <div class="form-actions">
            <button type="submit" class="btn btn-primary">
                <i class="fas fa-save"></i> Enregistrer l'hôtel
            </button>
            <a href="${pageContext.request.contextPath}/hotels/list" class="btn btn-secondary">
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
