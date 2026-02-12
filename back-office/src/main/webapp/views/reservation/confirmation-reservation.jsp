<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>

<div class="container">
    <div class="confirmation-message text-center">
        <div class="confirmation-icon text-success">
            <i class="fas fa-check-circle fa-3x"></i>
        </div>
        <h2 class="mb-4">Confirmation</h2>
        <p class="lead">${message}</p>
        <div class="actions mt-4">
            <a href="${pageContext.request.contextPath}/reservations/create" class="btn btn-primary mr-2">
                <i class="fas fa-plus"></i> Créer une autre réservation
            </a>
            <a href="${pageContext.request.contextPath}/reservations" class="btn btn-secondary">
                <i class="fas fa-list"></i> Voir la liste des réservations
            </a>
        </div>
    </div>
</div>

<style>
.confirmation-message {
    background: #f8f9fa;
    padding: 2rem;
    border-radius: 8px;
    margin: 2rem 0;
    box-shadow: 0 2px 4px rgba(0,0,0,0.1);
}

.confirmation-icon {
    margin-bottom: 1rem;
}

.actions .btn {
    margin: 0.5rem;
}
</style>
