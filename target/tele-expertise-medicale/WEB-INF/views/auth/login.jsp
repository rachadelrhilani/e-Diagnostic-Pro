<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<jsp:include page="../templates/header.jsp" />

<div class="max-w-md mx-auto bg-white p-8 rounded-xl shadow-md border border-gray-100 my-10">
    <h2 class="text-2xl font-bold text-center text-gray-900 mb-6">Connexion</h2>
    
    <c:if test="${not empty error}">
        <div class="bg-red-50 border-l-4 border-red-500 text-red-700 p-4 mb-6 text-sm rounded">
            ${error}
        </div>
    </c:if>

    <form action="${pageContext.request.contextPath}/auth/login" method="post" class="space-y-5">
        <input type="hidden" name="_csrf" value="${sessionScope.csrfToken}" />
        
        <div>
            <label for="email" class="block text-sm font-medium text-gray-700 mb-1">Adresse Email</label>
            <input type="email" id="email" name="email" required 
                   class="w-full px-4 py-2 border border-gray-300 rounded-lg focus:ring-2 focus:ring-indigo-500 focus:border-indigo-500 outline-none transition" />
        </div>
        
        <div>
            <label for="password" class="block text-sm font-medium text-gray-700 mb-1">Mot de passe</label>
            <input type="password" id="password" name="password" required 
                   class="w-full px-4 py-2 border border-gray-300 rounded-lg focus:ring-2 focus:ring-indigo-500 focus:border-indigo-500 outline-none transition" />
        </div>
        
        <button type="submit" 
                class="w-full bg-indigo-600 hover:bg-indigo-700 text-white font-medium py-2.5 rounded-lg shadow transition">
            Se connecter
        </button>
    </form>
</div>

