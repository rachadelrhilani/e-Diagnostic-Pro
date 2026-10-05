<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<!DOCTYPE html>
<html lang="fr" class="h-full bg-gray-50">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Télé-expertise Médicale</title>
    <script src="https://cdn.tailwindcss.com"></script>
</head>
<body class="h-full flex flex-col font-sans antialiased text-gray-800">

<header class="bg-indigo-600 text-white shadow-md">
    <div class="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8 py-4 flex justify-between items-center">
        <h1 class="text-xl font-bold tracking-wide">
            <a href="${pageContext.request.contextPath}/" class="hover:text-indigo-200 transition">Télé-Expertise Médicale</a>
        </h1>
        <c:if test="${not empty sessionScope.user}">
            <div class="flex items-center gap-4 text-sm">
                <span class="bg-indigo-700 px-3 py-1 rounded-full text-indigo-100 font-medium">
                    ${sessionScope.user.nom} ${sessionScope.user.prenom} (${sessionScope.user.role})
                </span>
                <a href="${pageContext.request.contextPath}/auth/logout" class="bg-red-500 hover:bg-red-600 text-white px-3 py-1.5 rounded-lg transition text-xs font-semibold">
                    Déconnexion
                </a>
            </div>
        </c:if>
    </div>
</header>

<main class="flex-1 max-w-7xl w-full mx-auto px-4 sm:px-6 lg:px-8 py-8">