<%@ page contentType="text/html;charset=UTF-8" language="java" isELIgnored="false" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<jsp:include page="../templates/header.jsp" />

<div class="max-w-4xl mx-auto space-y-6">
    <!-- En-tête -->
    <div class="flex flex-col md:flex-row md:items-center justify-between border-b border-slate-800 pb-4 gap-4">
        <div>
            <div class="flex items-center gap-2 mb-1">
                <span class="px-2.5 py-0.5 rounded-full bg-emerald-500/20 text-emerald-300 text-xs font-bold border border-emerald-500/30">
                    US3 : Télé-Expertise
                </span>
                <h2 class="text-2xl font-bold text-white tracking-wide">Choix du Créneau & Formulation de la Demande</h2>
            </div>
            <p class="text-sm text-slate-400">
                Sélectionnez un créneau horaire fixe prédéfini, posez votre question clinique et transmettez les analyses.
            </p>
        </div>

        <a href="${pageContext.request.contextPath}/generaliste/recherche-specialiste<c:if test="${not empty consultationId}">?consultationId=${consultationId}</c:if>" 
           class="px-4 py-2 rounded-xl bg-slate-800 hover:bg-slate-700 text-slate-300 text-xs font-semibold border border-slate-700 transition flex items-center gap-2">
            ⬅ Changer de spécialiste
        </a>
    </div>

    <!-- Récapitulatif du Spécialiste & Patient -->
    <div class="grid grid-cols-1 md:grid-cols-2 gap-4">
        <!-- Carte Spécialiste -->
        <div class="p-5 rounded-2xl bg-slate-800/50 border border-slate-700/60 backdrop-blur-md">
            <span class="text-xs font-semibold text-indigo-400 uppercase tracking-wider block mb-1">Médecin Spécialiste Sollicité</span>
            <h3 class="text-lg font-bold text-white">Dr. ${specialiste.prenom} ${specialiste.nom}</h3>
            <p class="text-xs text-slate-300 mt-0.5">Spécialité : <strong class="text-indigo-300">${specialiste.specialite}</strong></p>
            <div class="mt-3 flex items-center justify-between pt-3 border-t border-slate-700/60">
                <span class="text-xs text-slate-400">Tarif de l'expertise :</span>
                <span class="text-sm font-bold text-emerald-400 font-mono">${specialiste.tarif} DH</span>
            </div>
        </div>

        <!-- Carte Patient / Consultation -->
        <c:if test="${not empty consultation}">
            <div class="p-5 rounded-2xl bg-slate-800/50 border border-slate-700/60 backdrop-blur-md">
                <span class="text-xs font-semibold text-emerald-400 uppercase tracking-wider block mb-1">Dossier de Consultation</span>
                <h3 class="text-lg font-bold text-white">${consultation.patient.nom} ${consultation.patient.prenom}</h3>
                <p class="text-xs text-slate-300 mt-0.5">NSS : <span class="font-mono text-slate-400">${consultation.patient.numeroSecuriteSociale}</span></p>
                <div class="mt-3 flex items-center justify-between pt-3 border-t border-slate-700/60">
                    <span class="text-xs text-slate-400">Motif initial :</span>
                    <span class="text-xs text-white font-medium truncate max-w-[200px]">${consultation.motif}</span>
                </div>
            </div>
        </c:if>
    </div>

    <!-- Formulaire d'envoi de la demande de télé-expertise -->
    <form action="${pageContext.request.contextPath}/generaliste/envoyer-demande-expertise" method="post" 
          class="p-8 rounded-2xl bg-slate-800/40 border border-slate-700/60 backdrop-blur-md shadow-2xl space-y-6">
        
        <!-- Jeton CSRF obligatoire -->
        <input type="hidden" name="_csrf" value="${csrfToken}" />
        <input type="hidden" name="consultationId" value="${consultationId}" />
        <input type="hidden" name="specialisteId" value="${specialisteId}" />

        <!-- 1. Sélection du créneau horaire fixe -->
        <div>
            <label class="block text-xs font-semibold text-slate-300 uppercase tracking-wider mb-3">
                1. Sélectionner un Créneau Disponible (Horaires fixes prédéfinis) <span class="text-rose-400">*</span>
            </label>

            <c:choose>
                <c:when test="${not empty creneaux}">
                    <div class="grid grid-cols-1 sm:grid-cols-2 md:grid-cols-3 gap-3">
                        <c:forEach var="c" items="${creneaux}" varStatus="status">
                            <label class="relative flex flex-col p-4 rounded-xl bg-slate-900/90 border border-slate-700/80 cursor-pointer hover:border-indigo-500 hover:bg-slate-900 transition has-[:checked]:border-indigo-500 has-[:checked]:bg-indigo-950/30 has-[:checked]:ring-2 has-[:checked]:ring-indigo-500/40">
                                <div class="flex items-center justify-between mb-2">
                                    <span class="text-[11px] font-semibold text-indigo-400 uppercase tracking-wider">Créneau #${c.id}</span>
                                    <input type="radio" name="creneauId" value="${c.id}" ${status.first ? 'checked' : ''} required 
                                           class="text-indigo-600 focus:ring-indigo-500" />
                                </div>
                                <span class="text-sm font-bold text-white font-mono">
                                    ${c.heureDebut.toLocalDate()}
                                </span>
                                <span class="text-xs text-slate-300 font-mono mt-1">
                                    ${c.heureDebut.toLocalTime()} - ${c.heureFin.toLocalTime()}
                                </span>
                                <span class="mt-2 inline-flex items-center gap-1 text-[10px] text-emerald-400 font-semibold">
                                    <span class="w-1.5 h-1.5 rounded-full bg-emerald-400"></span> Disponible
                                </span>
                            </label>
                        </c:forEach>
                    </div>
                </c:when>
                <c:otherwise>
                    <div class="p-6 text-center rounded-xl bg-amber-500/10 border border-amber-500/30 text-amber-300 text-sm">
                        ⚠️ Aucun créneau futur disponible actuellement pour ce spécialiste.
                    </div>
                </c:otherwise>
            </c:choose>
        </div>

        <!-- 2. Degré d'urgence (Priorité) -->
        <div>
            <label class="block text-xs font-semibold text-slate-300 uppercase tracking-wider mb-2">
                2. Degré d'urgence (Priorité clinique) <span class="text-rose-400">*</span>
            </label>
            <select name="priorite" required 
                    class="w-full px-4 py-3 rounded-xl bg-slate-900 border border-slate-700 text-white text-sm focus:outline-none focus:border-indigo-500 transition">
                <option value="NORMALE" selected>NORMALE (Délai standard sous 24-48h)</option>
                <option value="URGENTE">URGENTE (Avis requis dans les plus brefs délais)</option>
                <option value="NON_URGENTE">NON_URGENTE (Suivi régulier / Avis différé)</option>
            </select>
        </div>

        <!-- 3. Question au spécialiste -->
        <div>
            <label class="block text-xs font-semibold text-slate-300 uppercase tracking-wider mb-2">
                3. Question clinique précise au spécialiste <span class="text-rose-400">*</span>
            </label>
            <textarea name="question" rows="3" required 
                      placeholder="Ex : Suspicion de cardiopathie ischémique avec anomalies du tracé ECG. Quel protocole thérapeutique préconisez-vous ?" 
                      class="w-full px-4 py-3 rounded-xl bg-slate-900 border border-slate-700 text-white text-sm placeholder-slate-500 focus:outline-none focus:border-indigo-500 transition"></textarea>
        </div>

        <!-- 4. Données et analyses fournies -->
        <div>
            <label class="block text-xs font-semibold text-slate-300 uppercase tracking-wider mb-2">
                4. Données cliniques et analyses transmises (US3)
            </label>
            <textarea name="donneesAnalyses" rows="3" 
                      placeholder="Transmettez ici les résultats d'analyses (biologie, bilan lipidique, radiologie, constantes physiologiques, antécédents)..." 
                      class="w-full px-4 py-3 rounded-xl bg-slate-900 border border-slate-700 text-white text-sm placeholder-slate-500 focus:outline-none focus:border-indigo-500 transition"></textarea>
            <span class="text-[11px] text-slate-400 mt-1 block">
                Ces données permettront au médecin spécialiste d'étayer son avis médical et ses recommandations.
            </span>
        </div>

        <!-- Bouton de confirmation -->
        <div class="pt-4 border-t border-slate-700/60 flex items-center justify-between">
            <span class="text-xs text-slate-400">
                L'envoi basculera la consultation au statut <span class="text-amber-400 font-semibold">EN_ATTENTE_AVIS_SPECIALISTE</span>.
            </span>
            <button type="submit" 
                    class="px-8 py-3.5 rounded-xl bg-indigo-600 hover:bg-indigo-500 text-white font-semibold text-sm shadow-xl shadow-indigo-600/30 transition flex items-center gap-2">
                <span>📨</span> Confirmer et Envoyer la Demande
            </button>
        </div>
    </form>
</div>

<jsp:include page="../templates/footer.jsp" />