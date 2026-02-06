<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib uri="jakarta.tags.core" prefix="c" %>
Le produit est : 
<c:if test="${not empty requestScope.product}">
    <br>${requestScope.product}
</c:if>