<%@ page contentType="text/html;charset=UTF-8" language="java" isELIgnored="false" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<%@ taglib prefix="fn" uri="jakarta.tags.functions" %>
<jsp:include page="../templates/header.jsp" />

<div class="space-y-8">
    <!-- En-tête -->
    <div class="flex flex-col md:flex-row md:items-center justify-between border-b border-slate-800 pb-5 gap-4">
        <div>
            <h2 class="text-2xl font-bold text-white tracking-wide flex items-center gap-2">
                <span>🩺</span> Espace Médecin Généraliste
            </h2>
            <p class="text-sm text-slate-400 mt-1">
                Création de consultations (150 DH fixe), suivi des dossiers et demandes de télé-expertise.
            </p>
        </div>
        <div class="flex items-center gap-3">
            <span class="px-3 py-1.5 rounded-lg bg-emerald-500/10 border border-emerald-500/30 text-emerald-400 text-xs font-semibold">
                Tarif Consultation Fixe : 150 DH
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

    <!-- US1 : Créer une Consultation -->
    <div class="p-6 rounded-2xl bg-slate-800/50 border border-slate-700/60 backdrop-blur-md shadow-xl">
        <div class="flex items-center justify-between mb-5">
            <div class="flex items-center gap-3">
                <div class="w-10 h-10 rounded-xl bg-indigo-600/20 border border-indigo-500/30 flex items-center justify-center text-indigo-400 font-bold">
                    US1
                </div>
                <div>
                    <h3 class="text-lg font-bold text-white">Créer une consultation</h3>
                    <p class="text-xs text-slate-400">Sélectionnez un patient existant et saisissez le motif et les observations</p>
                </div>
            </div>
            <span class="px-3 py-1 rounded-full bg-indigo-500/20 text-indigo-300 border border-indigo-500/40 text-xs font-semibold">
                Coût fixe : 150 DH
            </span>
        </div>

        <c:choose>
            <%-- Consultation déjà en cours : bloquer la création --%>
            <c:when test="${not empty mesConsultations}">
                <div class="p-5 rounded-xl bg-amber-500/10 border border-amber-500/30 flex flex-col sm:flex-row sm:items-center justify-between gap-4">
                    <div class="flex items-start gap-3">
                        <span class="text-2xl mt-0.5">🔒</span>
                        <div>
                            <p class="text-amber-300 font-semibold text-sm">Consultation déjà en cours</p>
                            <p class="text-slate-400 text-xs mt-0.5">
                                Vous avez déjà une consultation active pour
                                <strong class="text-white">${mesConsultations[0].patient.nom} ${mesConsultations[0].patient.prenom}</strong>
                                (Dossier #${mesConsultations[0].id}).
                                Clôturez-la avant d'en démarrer une nouvelle.
                            </p>
                        </div>
                    </div>
                    <a href="${pageContext.request.contextPath}/generaliste/detail-consultation?id=${mesConsultations[0].id}"
                       class="whitespace-nowrap inline-flex items-center gap-2 px-5 py-2.5 rounded-xl bg-amber-500 hover:bg-amber-400 text-slate-900 font-semibold text-xs transition shadow-md shadow-amber-500/20">
                        <span>📂</span> Ouvrir la consultation en cours ➔
                    </a>
                </div>
            </c:when>
            <%-- Pas de consultation active : afficher le formulaire --%>
            <c:otherwise>
                <form action="${pageContext.request.contextPath}/generaliste/creer-consultation" method="post" class="space-y-5">
                    <input type="hidden" name="_csrf" value="${csrfToken}" />
                    <div class="grid grid-cols-1 md:grid-cols-3 gap-5">
                        <!-- Sélection du patient existant -->
                        <div>
                            <label class="block text-xs font-semibold text-slate-300 uppercase tracking-wider mb-2">
                                Patient existant <span class="text-rose-400">*</span>
                            </label>
                            <select name="patientId" required class="w-full px-4 py-3 rounded-xl bg-slate-900/90 border border-slate-700 text-white text-sm focus:outline-none focus:border-indigo-500 transition">
                                <option value="" disabled selected>-- Sélectionner un patient --</option>
                                
                                <!-- Priority 1: Patients en attente du jour -->
                                <c:forEach var="p" items="${patientsEnAttente}">
                                    <option value="${p.id}">
                                        [En attente] ${p.nom} ${p.prenom} (NSS: ${p.numeroSecuriteSociale})
                                    </option>
                                </c:forEach>

                                <!-- Priority 2: Tous les autres patients -->
                                <c:forEach var="p" items="${tousLesPatients}">
                                    <option value="${p.id}">
                                        ${p.nom} ${p.prenom} (NSS: ${p.numeroSecuriteSociale})
                                    </option>
                                </c:forEach>
                            </select>
                        </div>

                        <!-- Motif de la consultation -->
                        <div>
                            <label class="block text-xs font-semibold text-slate-300 uppercase tracking-wider mb-2">
                                Motif de consultation <span class="text-rose-400">*</span>
                            </label>
                            <input type="text" name="motif" required placeholder="ex: Céphalées aiguës, Douleur thoracique..." 
                                   class="w-full px-4 py-3 rounded-xl bg-slate-900/90 border border-slate-700 text-white text-sm placeholder-slate-500 focus:outline-none focus:border-indigo-500 transition" />
                        </div>

                        <!-- Observations initiales -->
                        <div>
                            <label class="block text-xs font-semibold text-slate-300 uppercase tracking-wider mb-2">
                                Observations cliniques
                            </label>
                            <input type="text" name="observations" placeholder="Remarques cliniques initiales..." 
                                   class="w-full px-4 py-3 rounded-xl bg-slate-900/90 border border-slate-700 text-white text-sm placeholder-slate-500 focus:outline-none focus:border-indigo-500 transition" />
                        </div>
                    </div>

                    <div class="flex items-center justify-between pt-2">
                        <span class="text-xs text-slate-400 flex items-center gap-1.5">
                            <span>💡</span> La consultation est automatiquement enregistrée avec un tarif de base réglementaire de <strong>150 DH</strong>.
                        </span>
                        <button type="submit" class="px-6 py-3 rounded-xl bg-indigo-600 hover:bg-indigo-500 text-white font-semibold text-sm transition shadow-lg shadow-indigo-600/30 flex items-center gap-2">
                            <span>🩺</span> Démarrer la consultation (150 DH)
                        </button>
                    </div>
                </form>
            </c:otherwise>
        </c:choose>
    </div>

    <!-- Section : Mes Consultations en Cours & File d'attente -->
    <div class="p-6 rounded-2xl bg-slate-800/40 border border-slate-700/50 backdrop-blur-md shadow-xl">
        <div class="flex items-center justify-between mb-5">
            <div>
                <h3 class="text-lg font-bold text-white flex items-center gap-2">
                    <span>📋</span> Mes Consultations en Cours
                </h3>
                <p class="text-xs text-slate-400">Patients actuellement en charge ou orientés par l'infirmier</p>
            </div>
            <span class="px-3 py-1 rounded-full bg-slate-700 text-slate-300 text-xs font-semibold">
                ${not empty mesConsultations ? fn:length(mesConsultations) : 0} en cours
            </span>
        </div>

        <c:choose>
            <c:when test="${not empty mesConsultations}">
                <div class="overflow-x-auto">
                    <table class="w-full text-left text-sm text-slate-300">
                        <thead class="text-xs uppercase bg-slate-900/60 text-slate-400 border-b border-slate-700">
                            <tr>
                                <th class="px-4 py-3.5 rounded-l-xl">Dossier / Patient</th>
                                <th class="px-4 py-3.5">NSS</th>
                                <th class="px-4 py-3.5">Motif</th>
                                <th class="px-4 py-3.5">Statut</th>
                                <th class="px-4 py-3.5">Coût actuel</th>
                                <th class="px-4 py-3.5 text-right rounded-r-xl">Action</th>
                            </tr>
                        </thead>
                        <tbody class="divide-y divide-slate-800">
                            <c:forEach var="c" items="${mesConsultations}">
                                <tr class="hover:bg-slate-800/40 transition">
                                    <td class="px-4 py-4 font-semibold text-white">
                                        ${c.patient.nom} ${c.patient.prenom}
                                    </td>
                                    <td class="px-4 py-4 text-xs font-mono text-slate-400">
                                        ${c.patient.numeroSecuriteSociale}
                                    </td>
                                    <td class="px-4 py-4 text-sm text-slate-300 max-w-xs truncate">
                                        ${c.motif}
                                    </td>
                                    <td class="px-4 py-4">
                                        <c:choose>
                                            <c:when test="${c.statut == 'EN_COURS'}">
                                                <span class="px-2.5 py-1 rounded-full text-[11px] font-semibold bg-amber-500/20 text-amber-300 border border-amber-500/30">
                                                    En cours
                                                </span>
                                            </c:when>
                                            <c:when test="${c.statut == 'EN_ATTENTE_AVIS_SPECIALISTE'}">
                                                <span class="px-2.5 py-1 rounded-full text-[11px] font-semibold bg-purple-500/20 text-purple-300 border border-purple-500/30">
                                                    Avis spécialiste demandé
                                                </span>
                                            </c:when>
                                            <c:otherwise>
                                                <span class="px-2.5 py-1 rounded-full text-[11px] font-semibold bg-emerald-500/20 text-emerald-300 border border-emerald-500/30">
                                                    ${c.statut}
                                                </span>
                                            </c:otherwise>
                                        </c:choose>
                                    </td>
                                    <td class="px-4 py-4 text-sm font-semibold text-emerald-400 font-mono">
                                        ${c.coutTotal} DH
                                    </td>
                                    <td class="px-4 py-4 text-right">
                                        <a href="${pageContext.request.contextPath}/generaliste/detail-consultation?id=${c.id}" 
                                           class="inline-flex items-center gap-1.5 px-4 py-2 rounded-xl bg-indigo-600 hover:bg-indigo-500 text-white text-xs font-semibold transition shadow-md shadow-indigo-600/20">
                                            <span>Ouvrir dossier</span> ➔
                                        </a>
                                    </td>
                                </tr>
                            </c:forEach>
                        </tbody>
                    </table>
                </div>
            </c:when>
            <c:otherwise>
                <div class="p-8 text-center rounded-xl bg-slate-900/30 border border-dashed border-slate-700/60">
                    <p class="text-slate-400 text-sm">Aucune consultation en cours. Utilisez le formulaire ci-dessus pour démarrer une nouvelle consultation.</p>
                </div>
            </c:otherwise>
        </c:choose>
    </div>
</div>

<jsp:include page="../templates/footer.jsp" />