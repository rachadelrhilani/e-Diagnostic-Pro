<%@ page contentType="text/html;charset=UTF-8" language="java" isELIgnored="false"%>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<!DOCTYPE html>
<html lang="fr" class="h-full bg-slate-900">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Télé-expertise Médicale</title>
    <script src="https://cdn.tailwindcss.com"></script>
</head>
<body class="h-full flex bg-slate-900 text-slate-100 font-sans antialiased">

<c:if test="${not empty sessionScope.user}">
    <!-- Sidebar / Aside Navigation -->
    <aside class="w-64 bg-slate-800/60 backdrop-blur-md border-r border-slate-700/50 flex flex-col justify-between p-4 shrink-0">
        <div>
            <!-- Logo / App Name -->
            <div class="flex items-center gap-3 px-2 py-3 mb-6 border-b border-slate-700/50">
                <div class="w-8 h-8 rounded-lg bg-indigo-500 flex items-center justify-center font-bold text-white shadow-lg shadow-indigo-500/30">
                    T
                </div>
                <span class="font-bold text-lg text-white tracking-wide">Télé-Expertise</span>
            </div>

            <!-- Profile Info -->
            <div class="bg-slate-700/30 border border-slate-700/50 rounded-xl p-3 mb-6">
                <p class="text-xs text-slate-400 uppercase font-semibold tracking-wider">Connecté en tant que</p>
                <p class="text-sm font-semibold text-white truncate">${sessionScope.user.nom} ${sessionScope.user.prenom}</p>
                <span class="inline-block mt-1 px-2 py-0.5 text-[10px] font-bold uppercase rounded-full bg-indigo-500/20 text-indigo-300 border border-indigo-500/30">
                    ${sessionScope.user.role}
                </span>
            </div>

            <!-- Navigation Links -->
            <nav class="space-y-1">
                <c:if test="${sessionScope.user.role == 'INFIRMIER'}">
                    <a href="${pageContext.request.contextPath}/infirmier/dashboard" 
                       class="flex items-center gap-3 px-3 py-2.5 rounded-lg text-sm font-medium text-slate-200 hover:bg-slate-700/50 hover:text-white transition">
                        <span>📋</span> Patients du Jour
                    </a>
                    <a href="${pageContext.request.contextPath}/infirmier/recherche" 
                       class="flex items-center gap-3 px-3 py-2.5 rounded-lg text-sm font-medium text-slate-200 hover:bg-slate-700/50 hover:text-white transition">
                        <span>➕</span> Accueil Patient
                    </a>
                </c:if>

                <c:if test="${sessionScope.user.role == 'GENERALISTE'}">
                    <a href="${pageContext.request.contextPath}/generaliste/dashboard" 
                       class="flex items-center gap-3 px-3 py-2.5 rounded-lg text-sm font-medium text-slate-200 hover:bg-slate-700/50 hover:text-white transition">
                        <span>🩺</span> Consultations
                    </a>
                    <a href="${pageContext.request.contextPath}/generaliste/recherche-specialiste" 
                       class="flex items-center gap-3 px-3 py-2.5 rounded-lg text-sm font-medium text-slate-200 hover:bg-slate-700/50 hover:text-white transition">
                        <span>🔍</span> Trouver un Spécialiste
                    </a>
                </c:if>

                <c:if test="${sessionScope.user.role == 'SPECIALISTE'}">
                    <a href="${pageContext.request.contextPath}/specialiste/dashboard" 
                       class="flex items-center gap-3 px-3 py-2.5 rounded-lg text-sm font-medium text-slate-200 hover:bg-slate-700/50 hover:text-white transition">
                        <span>📩</span> Demandes reçues
                    </a>
                    <a href="${pageContext.request.contextPath}/specialiste/creneaux" 
                       class="flex items-center gap-3 px-3 py-2.5 rounded-lg text-sm font-medium text-slate-200 hover:bg-slate-700/50 hover:text-white transition">
                        <span>📅</span> Planning Créneaux
                    </a>
                    <a href="${pageContext.request.contextPath}/specialiste/profil" 
                       class="flex items-center gap-3 px-3 py-2.5 rounded-lg text-sm font-medium text-slate-200 hover:bg-slate-700/50 hover:text-white transition">
                        <span>⚙️</span> Configuration Profil
                    </a>
                </c:if>
            </nav>
        </div>

        <!-- Logout Button -->
        <div class="pt-4 border-t border-slate-700/50">
            <a href="${pageContext.request.contextPath}/auth/logout" 
               class="flex items-center justify-center gap-2 w-full py-2.5 px-4 rounded-lg bg-rose-500/10 hover:bg-rose-500/20 text-rose-400 border border-rose-500/20 font-medium text-sm transition">
                <span>🚪</span> Déconnexion
            </a>
        </div>
    </aside>
</c:if>

<!-- Main Content Wrapper -->
<main class="flex-1 overflow-y-auto p-8 bg-slate-900">