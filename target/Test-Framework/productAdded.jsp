<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib uri="jakarta.tags.core" prefix="c" %>

<c:set var="data" value="${requestScope.data}" />
<c:if test="${empty data}">
    Aucune donnée reçue.
    <c:redirect url="/" />
</c:if>
<c:set var="productName" value="${data.productName}" />
<c:set var="message" value="${data.message}" />
<c:set var="productList" value="${data.productList}" />
<h1>Confirmation</h1>
<p><b>${message}</b></p>
<p>Produit ajouté : ${productName}</p>

<c:if test="${not empty productList}">
    <h2>Liste actuelle des produits</h2>
    <ul>
    <c:forEach var="p" items="${productList}">
        <li>${p}</li>
    </c:forEach>
    </ul>
</c:if>