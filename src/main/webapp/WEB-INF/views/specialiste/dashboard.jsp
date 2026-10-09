<%@ page contentType="text/html;charset=UTF-8" language="java" isELIgnored="false" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<jsp:include page="../templates/header.jsp" />

<!-- En-tête de la page -->
<div class="flex items-center justify-between mb-8">
    <div>
        <h1 class="text-2xl font-bold text-white tracking-wide">Tableau de bord Spécialiste</h1>
        <p class="text-sm text-slate-400 mt-1">Gérez vos demandes d'expertise et vos créneaux de consultation.</p>
    </div>
    <div class="flex items-center gap-3">
        <a href="${pageContext.request.contextPath}/specialiste/creneaux" 
           class="px-4 py-2.5 rounded-xl bg-indigo-600 hover:bg-indigo-500 text-white font-semibold text-sm shadow-lg shadow-indigo-600/30 transition flex items-center gap-2">
            <span>📅</span> Gérer mes créneaux
        </a>
    </div>
</div>

<!-- Cartes Statistiques / KPIs -->
<div class="grid grid-cols-1 md:grid-cols-3 gap-6 mb-8">
    <div class="p-6 rounded-2xl bg-slate-800/40 border border-slate-700/50 backdrop-blur-md">
        <div class="flex items-center justify-between">
            <span class="text-xs uppercase font-semibold text-slate-400 tracking-wider">Demandes en attente</span>
            <span class="p-2 rounded-lg bg-amber-500/10 text-amber-400">📩</span>
        </div>
        <h3 class="text-3xl font-bold text-amber-400 mt-3">${demandesEnAttenteCount != null ? demandesEnAttenteCount : 0}</h3>
        <p class="text-xs text-slate-500 mt-1">Nécessite votre avis médical</p>
    </div>

    <div class="p-6 rounded-2xl bg-slate-800/40 border border-slate-700/50 backdrop-blur-md">
        <div class="flex items-center justify-between">
            <span class="text-xs uppercase font-semibold text-slate-400 tracking-wider">Avis rendus</span>
            <span class="p-2 rounded-lg bg-indigo-500/10 text-indigo-400">✅</span>
        </div>
        <h3 class="text-3xl font-bold text-indigo-400 mt-3">${avisRendusCount != null ? avisRendusCount : 0}</h3>
        <p class="text-xs text-slate-500 mt-1">Télé-expertises finalisées</p>
    </div>

    <div class="p-6 rounded-2xl bg-slate-800/40 border border-slate-700/50 backdrop-blur-md">
        <div class="flex items-center justify-between">
            <span class="text-xs uppercase font-semibold text-slate-400 tracking-wider">Créneaux libres</span>
            <span class="p-2 rounded-lg bg-emerald-500/10 text-emerald-400">🕒</span>
        </div>
        <h3 class="text-3xl font-bold text-emerald-400 mt-3">${creneauxDispoCount != null ? creneauxDispoCount : 0}</h3>
        <p class="text-xs text-slate-500 mt-1">Disponibilités ouvertes</p>
    </div>
</div>

<!-- Section Liste des Demandes de Télé-expertise -->
<!-- Alertes -->
<c:if test="${not empty param.msg}">
    <div class="p-4 rounded-xl bg-emerald-500/10 border border-emerald-500/30 text-emerald-300 text-sm flex items-center gap-2 shadow-lg shadow-emerald-500/5 mb-6">
        <span>✅</span> <span>${param.msg}</span>
    </div>
</c:if>
<c:if test="${not empty param.error}">
    <div class="p-4 rounded-xl bg-rose-500/10 border border-rose-500/30 text-rose-300 text-sm flex items-center gap-2 shadow-lg shadow-rose-500/5 mb-6">
        <span>⚠️</span> <span>${param.error}</span>
    </div>
</c:if>

<div class="rounded-2xl bg-slate-800/40 border border-slate-700/50 p-6 backdrop-blur-md">
    <div class="flex flex-col md:flex-row md:items-center justify-between gap-4 mb-6">
        <div>
            <h2 class="text-lg font-bold text-white flex items-center gap-2">
                <span>🩺</span> Demandes d'expertise reçues (US7)
            </h2>
            <p class="text-xs text-slate-400 mt-0.5">Filtrage instantané via Java Stream API par statut et priorité.</p>
        </div>

        <!-- Formulaire de filtrage par Statut et Priorité (Stream API) -->
        <form action="${pageContext.request.contextPath}/specialiste/dashboard" method="get" class="flex flex-wrap items-center gap-3">
            <select name="statut" onchange="this.form.submit()" class="bg-slate-900 border border-slate-700 text-xs text-slate-300 rounded-lg px-3 py-2 focus:outline-none focus:border-indigo-500">
                <option value="">Tous les statuts</option>
                <option value="EN_ATTENTE" ${param.statut == 'EN_ATTENTE' ? 'selected' : ''}>En attente</option>
                <option value="TERMINEE" ${param.statut == 'TERMINEE' ? 'selected' : ''}>Répondues / Terminées</option>
            </select>

            <select name="priorite" onchange="this.form.submit()" class="bg-slate-900 border border-slate-700 text-xs text-slate-300 rounded-lg px-3 py-2 focus:outline-none focus:border-indigo-500">
                <option value="">Toutes priorités</option>
                <option value="URGENTE" ${param.priorite == 'URGENTE' ? 'selected' : ''}>Urgent</option>
                <option value="NORMALE" ${param.priorite == 'NORMALE' ? 'selected' : ''}>Normale</option>
            </select>

            <c:if test="${not empty param.statut || not empty param.priorite}">
                <a href="${pageContext.request.contextPath}/specialiste/dashboard" class="text-xs text-indigo-400 hover:text-indigo-300 transition">
                    Réinitialiser
                </a>
            </c:if>
        </form>
    </div>

    <c:choose>
        <c:when test="${not empty demandes}">
            <div class="overflow-x-auto">
                <table class="w-full text-left text-sm text-slate-300">
                    <thead class="text-xs uppercase bg-slate-700/40 text-slate-400 border-b border-slate-700/50">
                        <tr>
                            <th class="px-4 py-3 rounded-l-xl">Patient (US7)</th>
                            <th class="px-4 py-3">Médecin Généraliste</th>
                            <th class="px-4 py-3">Question posée (US7)</th>
                            <th class="px-4 py-3">Priorité</th>
                            <th class="px-4 py-3">Date Demande</th>
                            <th class="px-4 py-3">Statut</th>
                            <th class="px-4 py-3 text-right rounded-r-xl">Action</th>
                        </tr>
                    </thead>
                    <tbody class="divide-y divide-slate-700/30">
                        <c:forEach var="demande" items="${demandes}">
                            <tr class="hover:bg-slate-700/20 transition">
                                <!-- Détails du patient (US7) -->
                                <td class="px-4 py-4">
                                    <div class="font-medium text-white">
                                        ${demande.consultation.patient.nom} ${demande.consultation.patient.prenom}
                                    </div>
                                    <div class="text-[11px] font-mono text-slate-400">
                                        NSS: ${demande.consultation.patient.numeroSecuriteSociale}
                                    </div>
                                </td>

                                <!-- Médecin Généraliste -->
                                <td class="px-4 py-4 text-slate-300">
                                    Dr. ${demande.consultation.generaliste.prenom} ${demande.consultation.generaliste.nom}
                                </td>

                                <!-- Question posée (US7) -->
                                <td class="px-4 py-4 max-w-xs truncate text-xs text-slate-300" title="${demande.question}">
                                    ${demande.question}
                                </td>

                                <!-- Priorité -->
                                <td class="px-4 py-4">
                                    <c:choose>
                                        <c:when test="${demande.priorite == 'URGENTE'}">
                                            <span class="px-2.5 py-1 text-xs rounded-lg bg-rose-500/20 text-rose-300 border border-rose-500/30 font-medium">Urgent</span>
                                        </c:when>
                                        <c:otherwise>
                                            <span class="px-2.5 py-1 text-xs rounded-lg bg-slate-700/50 text-slate-300 border border-slate-600/30 font-medium">Normale</span>
                                        </c:otherwise>
                                    </c:choose>
                                </td>

                                <!-- Date demande -->
                                <td class="px-4 py-4 text-xs text-slate-400">
                                    ${demande.dateDemande}
                                </td>

                                <!-- Statut -->
                                <td class="px-4 py-4">
                                    <c:choose>
                                        <c:when test="${demande.statut == 'EN_ATTENTE'}">
                                            <span class="px-2.5 py-1 text-xs rounded-lg bg-amber-500/20 text-amber-300 border border-amber-500/30 font-medium">En attente</span>
                                        </c:when>
                                        <c:when test="${demande.statut == 'TERMINEE'}">
                                            <span class="px-2.5 py-1 text-xs rounded-lg bg-emerald-500/20 text-emerald-300 border border-emerald-500/30 font-medium">Répondue</span>
                                        </c:when>
                                        <c:otherwise>
                                            <span class="px-2.5 py-1 text-xs rounded-lg bg-indigo-500/20 text-indigo-300 border border-indigo-500/30 font-medium">${demande.statut}</span>
                                        </c:otherwise>
                                    </c:choose>
                                </td>

                                <!-- Action : Examiner (US7 / US8) -->
                                <td class="px-4 py-4 text-right">
                                    <a href="${pageContext.request.contextPath}/specialiste/expertise?id=${demande.id}" 
                                       class="px-3.5 py-1.5 rounded-lg bg-indigo-600 hover:bg-indigo-500 text-white text-xs font-semibold transition inline-flex items-center gap-1 shadow-md shadow-indigo-600/20">
                                        <span>Examiner</span> ➔
                                    </a>
                                </td>
                            </tr>
                        </c:forEach>
                    </tbody>
                </table>
            </div>
        </c:when>
        <c:otherwise>
            <div class="text-center py-12 border border-dashed border-slate-700/50 rounded-xl bg-slate-800/20">
                <p class="text-slate-400 text-sm">Aucune demande d'expertise ne correspond aux critères.</p>
            </div>
        </c:otherwise>
    </c:choose>
</div>
<jsp:include page="../templates/footer.jsp" />