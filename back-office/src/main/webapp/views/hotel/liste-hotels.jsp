<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>

<div class="container">
    <div class="page-header">
        <h1>Liste des hôtels</h1>
        <a href="${pageContext.request.contextPath}/hotels/create" class="btn btn-primary">
            <i class="fas fa-plus"></i> Ajouter un hôtel
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
                    <th>Nom</th>
                    <th>Ville</th>
                    <th>Pays</th>
                    <th>Étoiles</th>
                    <th>Statut</th>
                    <th>Actions</th>
                </tr>
            </thead>
            <tbody>
                <c:forEach items="${hotels}" var="hotel">
                    <tr>
                        <td><strong>${hotel.nom}</strong></td>
                        <td>${hotel.ville}</td>
                        <td>${hotel.pays}</td>
                        <td>
                            <c:forEach begin="1" end="${hotel.nombreEtoiles}">⭐</c:forEach>
                        </td>
                        <td>
                            <span class="badge ${hotel.active ? 'badge-success' : 'badge-danger'}">
                                ${hotel.active ? 'Actif' : 'Inactif'}
                            </span>
                        </td>
                        <td class="actions">
                            <a href="${pageContext.request.contextPath}/hotels/view?id=${hotel.id}" 
                               class="btn btn-sm btn-info" title="Voir">
                                <i class="fas fa-eye"></i>
                            </a>
                            <a href="${pageContext.request.contextPath}/hotels/edit?id=${hotel.id}" 
                               class="btn btn-sm btn-warning" title="Modifier">
                                <i class="fas fa-edit"></i>
                            </a>
                            <form action="${pageContext.request.contextPath}/hotels/delete" 
                                  method="post" style="display: inline;">
                                <input type="hidden" name="id" value="${hotel.id}">
                                <button type="submit" class="btn btn-sm btn-danger" title="Supprimer" 
                                        onclick="return confirm('Êtes-vous sûr de vouloir supprimer cet hôtel ?')">
                                    <i class="fas fa-trash"></i>
                                </button>
                            </form>
                        </td>
                    </tr>
                </c:forEach>
            </tbody>
        </table>
    </div>
    
    <c:if test="${empty hotels}">
        <div class="empty-state text-center py-5">
            <i class="fas fa-hotel fa-3x mb-3 text-muted"></i>
            <h3>Aucun hôtel trouvé</h3>
            <p>Commencez par ajouter votre premier hôtel.</p>
            <a href="${pageContext.request.contextPath}/hotels/create" class="btn btn-primary">
                <i class="fas fa-plus"></i> Ajouter un hôtel
            </a>
        </div>
    </c:if>
</div>
