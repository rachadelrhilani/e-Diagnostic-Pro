<%@ page contentType="text/html;charset=UTF-8" language="java" isELIgnored="false" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<%@ taglib prefix="fn" uri="jakarta.tags.functions" %>
<jsp:include page="../templates/header.jsp" />

<div class="space-y-8">
    <!-- En-tête -->
    <div class="flex flex-col md:flex-row md:items-center justify-between border-b border-slate-800 pb-5 gap-4">
        <div>
            <h1 class="text-2xl font-bold text-white tracking-wide flex items-center gap-2">
                <span>📅</span> Gestion des Créneaux de Disponibilité
            </h1>
            <p class="text-sm text-slate-400 mt-1">
                US6 : Définissez vos plages horaires de 30 min. Les créneaux passés sont automatiquement désactivés et archivés.
            </p>
        </div>
        <div class="flex items-center gap-3">
            <span class="px-3.5 py-1.5 rounded-xl bg-indigo-500/10 border border-indigo-500/30 text-indigo-400 text-xs font-semibold">
                Durée fixe par créneau : 30 min
            </span>
        </div>
    </div>

    <!-- Alertes -->
    <c:if test="${not empty param.msg}">
        <div class="p-4 rounded-xl bg-emerald-500/10 border border-emerald-500/30 text-emerald-300 text-sm flex items-center gap-2 shadow-lg shadow-emerald-500/5">
            <span>✅</span> <span>${param.msg}</span>
        </div>
    </c:if>
    <c:if test="${not empty param.error}">
        <div class="p-4 rounded-xl bg-rose-500/10 border border-rose-500/30 text-rose-300 text-sm flex items-center gap-2 shadow-lg shadow-rose-500/5">
            <span>⚠️</span> <span>${param.error}</span>
        </div>
    </c:if>

    <!-- Section 1 : Création / Configuration des disponibilités -->
    <div class="rounded-2xl bg-slate-800/40 border border-slate-700/50 p-6 md:p-8 backdrop-blur-md shadow-xl">
        <div class="flex flex-col md:flex-row md:items-center justify-between gap-4 mb-6">
            <div>
                <h2 class="text-lg font-bold text-white flex items-center gap-2">
                    <span>➕</span> Ouvrir des disponibilités (créneaux de 30 min)
                </h2>
                <p class="text-xs text-slate-400 mt-0.5">
                    Sélectionnez une date puis cochez les créneaux horaires que vous souhaitez rendre disponibles pour télé-expertise.
                </p>
            </div>

            <!-- Sélecteur de date -->
            <form id="dateForm" action="${pageContext.request.contextPath}/specialiste/creneaux" method="get" class="flex items-center gap-3">
                <label for="datePicker" class="text-xs font-semibold text-slate-300 uppercase tracking-wider">Date :</label>
                <input type="date" id="datePicker" name="date" value="${selectedDate}" min="${todayDate}"
                       onchange="this.form.submit()"
                       class="px-3.5 py-2 rounded-xl bg-slate-900 border border-slate-700 text-white text-sm focus:outline-none focus:border-indigo-500 transition cursor-pointer" />
            </form>
        </div>

        <!-- Règle métier explicative -->
        <div class="mb-6 p-4 rounded-xl bg-indigo-500/10 border border-indigo-500/20 text-xs text-indigo-300 flex items-start gap-3">
            <span class="text-base mt-0.5">💡</span>
            <div>
                <strong class="font-semibold text-white">Règle de désactivation automatique :</strong>
                <span>
                    Au moment de créer vos disponibilités, tout créneau dont l'heure est déjà passée par rapport à l'heure actuelle
                    (pour la date du jour : <strong>${todayDate}</strong>) est <strong>automatiquement désactivé</strong> et grisé.
                    Seules les tranches horaires futures peuvent être ouvertes.
                </span>
            </div>
        </div>

        <!-- Formulaire d'enregistrement des créneaux -->
        <form action="${pageContext.request.contextPath}/specialiste/creer-disponibilites" method="post" id="slotsForm">
            <input type="hidden" name="_csrf" value="${csrfToken}" />
            <input type="hidden" name="date" value="${selectedDate}" />

            <!-- Barre d'outils de sélection -->
            <div class="flex items-center justify-between mb-4 pb-3 border-b border-slate-700/40">
                <span class="text-xs font-semibold uppercase tracking-wider text-slate-400">
                    Tranches horaires disponibles pour le <span class="text-indigo-400">${selectedDate}</span> :
                </span>
                <div class="flex items-center gap-2">
                    <button type="button" onclick="cocherTous()" 
                            class="text-xs px-3 py-1.5 rounded-lg bg-slate-700 hover:bg-slate-600 text-slate-200 transition font-medium">
                        Tout sélectionner
                    </button>
                    <button type="button" onclick="decocherTous()" 
                            class="text-xs px-3 py-1.5 rounded-lg bg-slate-800 hover:bg-slate-700 text-slate-400 transition font-medium">
                        Tout désélectionner
                    </button>
                </div>
            </div>

            <!-- Grille des créneaux -->
            <div class="grid grid-cols-2 sm:grid-cols-3 md:grid-cols-4 lg:grid-cols-6 gap-3 mb-6">
                <c:forEach var="slot" items="${grille}">
                    <c:choose>
                        <%-- CAS 1 : Créneau passé pour aujourd'hui (DÉSACTIVÉ) --%>
                        <c:when test="${slot.passe}">
                            <div class="p-3.5 rounded-xl border border-slate-800/80 bg-slate-900/60 opacity-40 cursor-not-allowed flex flex-col justify-between select-none">
                                <div class="flex items-center justify-between">
                                    <span class="text-sm font-semibold font-mono text-slate-500 line-through">
                                        ${slot.heureDebut}
                                    </span>
                                    <span class="text-[10px] text-slate-500 font-mono">30m</span>
                                </div>
                                <div class="mt-2 flex items-center justify-between">
                                    <span class="text-[10px] font-semibold text-rose-400/80 bg-rose-500/10 px-1.5 py-0.5 rounded border border-rose-500/20">
                                        ⏱️ Passé
                                    </span>
                                    <input type="checkbox" disabled class="rounded bg-slate-800 border-slate-700 cursor-not-allowed opacity-30" />
                                </div>
                            </div>
                        </c:when>

                        <%-- CAS 2 : Créneau déjà existant en base (DÉSACTIVÉ avec statut) --%>
                        <c:when test="${slot.dejaExistant}">
                            <div class="p-3.5 rounded-xl border border-slate-700/60 bg-slate-800/80 cursor-not-allowed flex flex-col justify-between select-none">
                                <div class="flex items-center justify-between">
                                    <span class="text-sm font-semibold font-mono text-slate-300">
                                        ${slot.heureDebut}
                                    </span>
                                    <span class="text-[10px] text-slate-400 font-mono">30m</span>
                                </div>
                                <div class="mt-2 flex items-center justify-between">
                                    <c:choose>
                                        <c:when test="${slot.creneauExistant.statut == 'RESERVE'}">
                                            <span class="text-[10px] font-semibold text-purple-300 bg-purple-500/20 px-1.5 py-0.5 rounded border border-purple-500/30">
                                                🟣 Réservé
                                            </span>
                                        </c:when>
                                        <c:when test="${slot.creneauExistant.statut == 'ARCHIVE'}">
                                            <span class="text-[10px] font-semibold text-slate-400 bg-slate-700/40 px-1.5 py-0.5 rounded border border-slate-600/30">
                                                📁 Archivé
                                            </span>
                                        </c:when>
                                        <c:otherwise>
                                            <span class="text-[10px] font-semibold text-emerald-300 bg-emerald-500/20 px-1.5 py-0.5 rounded border border-emerald-500/30">
                                                ✅ Déjà ouvert
                                            </span>
                                        </c:otherwise>
                                    </c:choose>
                                    <input type="checkbox" checked disabled class="rounded bg-emerald-600 border-emerald-500 cursor-not-allowed" />
                                </div>
                            </div>
                        </c:when>

                        <%-- CAS 3 : Créneau futur sélectionnable (ACTIF) --%>
                        <c:otherwise>
                            <label class="p-3.5 rounded-xl border border-slate-700 bg-slate-900/90 hover:border-indigo-500 hover:bg-indigo-500/5 cursor-pointer transition flex flex-col justify-between group">
                                <div class="flex items-center justify-between">
                                    <span class="text-sm font-semibold font-mono text-white group-hover:text-indigo-300 transition">
                                        ${slot.heureDebut}
                                    </span>
                                    <span class="text-[10px] text-slate-400 font-mono">30m</span>
                                </div>
                                <div class="mt-2 flex items-center justify-between">
                                    <span class="text-[10px] font-medium text-emerald-400 bg-emerald-500/10 px-1.5 py-0.5 rounded border border-emerald-500/20">
                                        Disponible
                                    </span>
                                    <input type="checkbox" name="heures" value="${slot.heureDebut}" 
                                           class="slot-checkbox w-4 h-4 rounded bg-slate-800 border-slate-600 text-indigo-600 focus:ring-indigo-500 focus:ring-offset-slate-900 cursor-pointer" />
                                </div>
                            </label>
                        </c:otherwise>
                    </c:choose>
                </c:forEach>
            </div>

            <!-- Soumission -->
            <div class="flex items-center justify-end">
                <button type="submit" 
                        class="px-6 py-3 rounded-xl bg-indigo-600 hover:bg-indigo-500 text-white text-sm font-semibold shadow-lg shadow-indigo-600/30 transition flex items-center gap-2">
                    <span>💾</span> Enregistrer les créneaux sélectionnés
                </button>
            </div>
        </form>
    </div>

    <!-- Section 2 : Tableau récapitulatif des créneaux existants -->
    <div class="rounded-2xl bg-slate-800/40 border border-slate-700/50 p-6 md:p-8 backdrop-blur-md shadow-xl">
        <div class="flex flex-col md:flex-row md:items-center justify-between gap-4 mb-6">
            <div>
                <h2 class="text-lg font-bold text-white flex items-center gap-2">
                    <span>📋</span> Historique & Planning de tous vos créneaux
                </h2>
                <p class="text-xs text-slate-400 mt-0.5">
                    Mise à jour automatique : réservé = indisponible, passé = archivé automatiquement, annulation = redevient disponible.
                </p>
            </div>
            <span class="px-3 py-1 rounded-full bg-slate-700 text-slate-300 text-xs font-semibold">
                ${not empty creneaux ? fn:length(creneaux) : 0} créneau(x) au total
            </span>
        </div>

        <c:choose>
            <c:when test="${not empty creneaux}">
                <div class="overflow-x-auto">
                    <table class="w-full text-left text-sm text-slate-300">
                        <thead class="text-xs uppercase bg-slate-900/60 text-slate-400 border-b border-slate-700">
                            <tr>
                                <th class="px-4 py-3.5 rounded-l-xl">ID</th>
                                <th class="px-4 py-3.5">Date</th>
                                <th class="px-4 py-3.5">Plage Horaire</th>
                                <th class="px-4 py-3.5">Durée</th>
                                <th class="px-4 py-3.5">Statut du créneau</th>
                                <th class="px-4 py-3.5 text-right rounded-r-xl">Action</th>
                            </tr>
                        </thead>
                        <tbody class="divide-y divide-slate-800">
                            <c:forEach var="c" items="${creneaux}">
                                <tr class="hover:bg-slate-800/40 transition">
                                    <td class="px-4 py-4 text-xs font-mono text-slate-400">#${c.id}</td>
                                    <td class="px-4 py-4 font-medium text-white">
                                        ${c.heureDebut.toLocalDate()}
                                    </td>
                                    <td class="px-4 py-4 font-mono text-slate-300">
                                        ${c.heureDebut.toLocalTime()} - ${c.heureFin.toLocalTime()}
                                    </td>
                                    <td class="px-4 py-4 text-xs text-slate-400 font-mono">
                                        30 min
                                    </td>
                                    <td class="px-4 py-4">
                                        <c:choose>
                                            <c:when test="${c.statut == 'DISPONIBLE'}">
                                                <span class="px-2.5 py-1 rounded-full text-[11px] font-semibold bg-emerald-500/20 text-emerald-300 border border-emerald-500/30">
                                                    🟢 Disponible
                                                </span>
                                            </c:when>
                                            <c:when test="${c.statut == 'RESERVE'}">
                                                <span class="px-2.5 py-1 rounded-full text-[11px] font-semibold bg-purple-500/20 text-purple-300 border border-purple-500/30">
                                                    🟣 Réservé (Indisponible)
                                                </span>
                                            </c:when>
                                            <c:when test="${c.statut == 'ARCHIVE'}">
                                                <span class="px-2.5 py-1 rounded-full text-[11px] font-semibold bg-slate-700/50 text-slate-400 border border-slate-600/30">
                                                    📁 Passé (Archivé)
                                                </span>
                                            </c:when>
                                            <c:otherwise>
                                                <span class="px-2.5 py-1 rounded-full text-[11px] font-semibold bg-amber-500/20 text-amber-300 border border-amber-500/30">
                                                    ${c.statut}
                                                </span>
                                            </c:otherwise>
                                        </c:choose>
                                    </td>
                                    <td class="px-4 py-4 text-right">
                                        <c:if test="${c.statut == 'DISPONIBLE'}">
                                            <form action="${pageContext.request.contextPath}/specialiste/annuler-creneau" method="post" class="inline"
                                                  onsubmit="return confirm('Voulez-vous vraiment supprimer ce créneau disponible ?');">
                                                <input type="hidden" name="_csrf" value="${csrfToken}" />
                                                <input type="hidden" name="creneauId" value="${c.id}" />
                                                <button type="submit" 
                                                        class="px-3 py-1.5 rounded-lg bg-rose-500/10 hover:bg-rose-500/20 border border-rose-500/30 text-rose-300 text-xs font-semibold transition">
                                                    🗑️ Supprimer
                                                </button>
                                            </form>
                                        </c:if>
                                        <c:if test="${c.statut == 'RESERVE'}">
                                            <span class="text-xs text-slate-500 italic">Associé à une expertise</span>
                                        </c:if>
                                        <c:if test="${c.statut == 'ARCHIVE'}">
                                            <span class="text-xs text-slate-600">Historique</span>
                                        </c:if>
                                    </td>
                                </tr>
                            </c:forEach>
                        </tbody>
                    </table>
                </div>
            </c:when>
            <c:otherwise>
                <div class="p-8 text-center rounded-xl bg-slate-900/30 border border-dashed border-slate-700/60">
                    <p class="text-slate-400 text-sm">Aucun créneau configuré pour le moment. Utilisez la grille ci-dessus pour ouvrir vos premières disponibilités.</p>
                </div>
            </c:otherwise>
        </c:choose>
    </div>
</div>

<script>
function cocherTous() {
    document.querySelectorAll('.slot-checkbox').forEach(cb => {
        if (!cb.disabled) cb.checked = true;
    });
}
function decocherTous() {
    document.querySelectorAll('.slot-checkbox').forEach(cb => {
        if (!cb.disabled) cb.checked = false;
    });
}
</script>

<jsp:include page="../templates/footer.jsp" />
