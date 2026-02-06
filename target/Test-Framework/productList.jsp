<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib uri="jakarta.tags.core" prefix="c" %>

<c:set var="productList" value="${requestScope.productList}" />

<!DOCTYPE html>
<html>
<head>
    <meta charset="UTF-8">
    <title>Produit Ajouté</title>
</head>
<body>
    <h1>Produit ajouté avec succès !</h1>
    
    <h2>Liste des produits :</h2>
    <ul>
 <c:if test="${not empty productList}">
     <c:forEach var="product" items="${productList}">
         <li>${product}</li>
     </c:forEach>
 </c:if>
    </ul>
    
    <a href="productForm.jsp">Ajouter un autre produit</a>
</body>
</html>