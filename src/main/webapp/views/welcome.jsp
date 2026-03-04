<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>

<%-- Header commun : sidebar + barre de navigation --%>
<%@ include file="/views/components/header.jsp" %>

<div class="container">
    <h1>Tableau de Bord</h1>
    <p class="subtitle">Bienvenue, ${sessionScope.userName}</p>

    <%-- Cartes statistiques --%>
    <div class="stats-grid">
        <div class="stat-card">
            <h3>Hôtels</h3>
            <p class="stat-number">${totalHotels}</p>
            <a href="${pageContext.request.contextPath}/hotels/list">Voir la liste</a>
        </div>
        <div class="stat-card">
            <h3>Réservations</h3>
            <p class="stat-number">${totalReservations}</p>
            <a href="${pageContext.request.contextPath}/reservations">Voir la liste</a>
        </div>
    </div>

    <%-- Accès rapides --%>
    <div class="quick-actions">
        <h2>Accès Rapides</h2>
        <div class="actions-grid">
            <a href="${pageContext.request.contextPath}/reservations/create" class="action-card">
                + Nouvelle Réservation
            </a>
            <a href="${pageContext.request.contextPath}/hotels/create" class="action-card">
                + Nouvel Hôtel
            </a>
            <a href="${pageContext.request.contextPath}/clients/create" class="action-card">
                + Nouveau Client
            </a>
        </div>
    </div>
</div>

<style>
.subtitle {
    color: #666;
    margin-bottom: 2rem;
}
.stats-grid {
    display: grid;
    grid-template-columns: repeat(auto-fit, minmax(200px, 1fr));
    gap: 1.5rem;
    margin-bottom: 2rem;
}
.stat-card {
    background: white;
    border-radius: 8px;
    padding: 1.5rem;
    box-shadow: 0 2px 4px rgba(0,0,0,0.1);
    text-align: center;
}
.stat-card h3 {
    margin: 0 0 0.5rem;
    color: #333;
}
.stat-number {
    font-size: 2.5rem;
    font-weight: bold;
    color: #2196F3;
    margin: 0.5rem 0;
}
.stat-card a {
    color: #2196F3;
    text-decoration: none;
}
.quick-actions {
    margin-top: 2rem;
}
.quick-actions h2 {
    margin-bottom: 1rem;
}
.actions-grid {
    display: grid;
    grid-template-columns: repeat(auto-fit, minmax(200px, 1fr));
    gap: 1rem;
}
.action-card {
    display: flex;
    align-items: center;
    justify-content: center;
    background: #2196F3;
    color: white;
    padding: 1rem;
    border-radius: 8px;
    text-decoration: none;
    font-weight: bold;
    transition: background 0.3s;
}
.action-card:hover {
    background: #1976D2;
}
</style>

<%-- Footer commun : ferme le layout et charge les scripts --%>
<%@ include file="/views/components/footer.jsp" %>
