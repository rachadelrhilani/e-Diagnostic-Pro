<%@ page contentType="text/html;charset=UTF-8" language="java" isELIgnored="false" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<%@ taglib prefix="fn" uri="jakarta.tags.functions" %>
<jsp:include page="../templates/header.jsp" />

<div class="space-y-8">
    <!-- En-tête -->
    <div class="flex flex-col md:flex-row md:items-center justify-between border-b border-slate-800 pb-5 gap-4">
        <div>
            <div class="flex items-center gap-3">
                <a href="${pageContext.request.contextPath}/specialiste/dashboard" 
                   class="text-xs text-indigo-400 hover:text-indigo-300 transition flex items-center gap-1 font-semibold">
                    ← Retour aux demandes
                </a>
            </div>
            <h1 class="text-2xl font-bold text-white tracking-wide mt-2 flex items-center gap-2">
                <span>🩺</span> Dossier de Télé-expertise #${demande.id}
            </h1>
            <p class="text-sm text-slate-400 mt-1">
                US7 & US8 : Examen clinique du patient, analyse de la question posée et formulation de l'avis médical.
            </p>
        </div>
        <div class="flex flex-wrap items-center gap-2">
            <!-- Priorité -->
            <c:choose>
                <c:when test="${demande.priorite == 'URGENTE'}">
                    <span class="px-3 py-1.5 rounded-xl bg-rose-500/20 text-rose-300 border border-rose-500/30 text-xs font-bold">
                        🚨 Priorité URGENTE
                    </span>
                </c:when>
                <c:otherwise>
                    <span class="px-3 py-1.5 rounded-xl bg-slate-700/60 text-slate-300 border border-slate-600/30 text-xs font-semibold">
                        Priorité NORMALE
                    </span>
                </c:otherwise>
            </c:choose>

            <!-- Statut -->
            <c:choose>
                <c:when test="${demande.statut == 'EN_ATTENTE'}">
                    <span class="px-3 py-1.5 rounded-xl bg-amber-500/20 text-amber-300 border border-amber-500/30 text-xs font-bold">
                        ⏳ En attente de votre avis
                    </span>
                </c:when>
                <c:when test="${demande.statut == 'TERMINEE'}">
                    <span class="px-3 py-1.5 rounded-xl bg-emerald-500/20 text-emerald-300 border border-emerald-500/30 text-xs font-bold">
                        ✅ Expertise Terminée
                    </span>
                </c:when>
                <c:when test="${demande.statut == 'ANNULEE'}">
                    <span class="px-3 py-1.5 rounded-xl bg-rose-500/20 text-rose-300 border border-rose-500/30 text-xs font-bold">
                        ❌ Avis annulé — créneau libéré
                    </span>
                </c:when>
                <c:otherwise>
                    <span class="px-3 py-1.5 rounded-xl bg-slate-700 text-slate-300 text-xs font-semibold">
                        ${demande.statut}
                    </span>
                </c:otherwise>
            </c:choose>
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

    <!-- Grille Principale -->
    <div class="grid grid-cols-1 lg:grid-cols-3 gap-8">
        
        <!-- Colonne Gauche (1/3) : Fiche Patient & Signes Vitaux (US7) -->
        <div class="space-y-6">
            <!-- Fiche Patient -->
            <div class="rounded-2xl bg-slate-800/40 border border-slate-700/50 p-6 backdrop-blur-md">
                <h2 class="text-base font-bold text-white flex items-center gap-2 mb-4 border-b border-slate-700/50 pb-3">
                    <span>👤</span> Fiche Patient
                </h2>
                <div class="space-y-3 text-sm">
                    <div>
                        <span class="text-xs text-slate-400 block">Nom & Prénom</span>
                        <span class="text-white font-semibold text-base">
                            ${demande.consultation.patient.nom} ${demande.consultation.patient.prenom}
                        </span>
                    </div>
                    <div>
                        <span class="text-xs text-slate-400 block">Numéro Sécurité Sociale (NSS)</span>
                        <span class="text-indigo-400 font-mono font-medium">
                            ${demande.consultation.patient.numeroSecuriteSociale}
                        </span>
                    </div>
                    <div class="grid grid-cols-2 gap-2">
                        <div>
                            <span class="text-xs text-slate-400 block">Date de Naissance</span>
                            <span class="text-slate-200">${demande.consultation.patient.dateNaissance}</span>
                        </div>
                        <div>
                            <span class="text-xs text-slate-400 block">Mutuelle</span>
                            <span class="text-slate-200">${not empty demande.consultation.patient.mutuelle ? demande.consultation.patient.mutuelle : 'Aucune'}</span>
                        </div>
                    </div>
                    <div>
                        <span class="text-xs text-slate-400 block">Téléphone</span>
                        <span class="text-slate-200">${demande.consultation.patient.telephone}</span>
                    </div>
                    <div>
                        <span class="text-xs text-slate-400 block">Adresse</span>
                        <span class="text-slate-200">${demande.consultation.patient.adresse}</span>
                    </div>
                </div>

                <!-- Antécédents & Allergies -->
                <div class="mt-5 pt-4 border-t border-slate-700/50 space-y-3">
                    <div>
                        <span class="text-xs font-semibold text-slate-400 uppercase tracking-wider block mb-1">Antécédents Médicaux</span>
                        <p class="text-xs text-slate-300 bg-slate-900/60 p-2.5 rounded-lg border border-slate-800">
                            ${not empty demande.consultation.patient.antecedents ? demande.consultation.patient.antecedents : 'Aucun antécédent particulier renseigné.'}
                        </p>
                    </div>
                    <div>
                        <span class="text-xs font-semibold text-rose-400 uppercase tracking-wider block mb-1">Allergies connues</span>
                        <p class="text-xs text-rose-300 bg-rose-500/10 p-2.5 rounded-lg border border-rose-500/20">
                            ${not empty demande.consultation.patient.allergies ? demande.consultation.patient.allergies : 'Aucune allergie connue.'}
                        </p>
                    </div>
                </div>
            </div>

            <!-- Signes Vitaux (si disponibles) -->
            <c:if test="${not empty demande.consultation.patient.signesVitaux}">
                <div class="rounded-2xl bg-slate-800/40 border border-slate-700/50 p-6 backdrop-blur-md">
                    <h2 class="text-base font-bold text-white flex items-center gap-2 mb-4 border-b border-slate-700/50 pb-3">
                        <span>💓</span> Derniers Signes Vitaux
                    </h2>
                    <c:forEach var="sv" items="${demande.consultation.patient.signesVitaux}" varStatus="status">
                        <c:if test="${status.last}">
                            <div class="grid grid-cols-2 gap-3 text-xs">
                                <div class="bg-slate-900/60 p-2.5 rounded-xl border border-slate-800">
                                    <span class="text-slate-400 block">Tension</span>
                                    <span class="text-white font-bold text-sm">${not empty sv.tensionArterielle ? sv.tensionArterielle : sv.tension}</span>
                                </div>
                                <div class="bg-slate-900/60 p-2.5 rounded-xl border border-slate-800">
                                    <span class="text-slate-400 block">Température</span>
                                    <span class="text-white font-bold text-sm">${sv.temperature} °C</span>
                                </div>
                                <div class="bg-slate-900/60 p-2.5 rounded-xl border border-slate-800">
                                    <span class="text-slate-400 block">Fréq. Cardiaque</span>
                                    <span class="text-white font-bold text-sm">${sv.frequenceCardiaque} bpm</span>
                                </div>
                                <div class="bg-slate-900/60 p-2.5 rounded-xl border border-slate-800">
                                    <span class="text-slate-400 block">Poids / Taille</span>
                                    <span class="text-white font-bold text-sm">${sv.poids} kg / ${sv.taille} cm</span>
                                </div>
                            </div>
                        </c:if>
                    </c:forEach>
                </div>
            </c:if>

            <!-- Médecin Généraliste Demandeur -->
            <div class="rounded-2xl bg-slate-800/40 border border-slate-700/50 p-6 backdrop-blur-md">
                <h2 class="text-base font-bold text-white flex items-center gap-2 mb-3">
                    <span>👨‍⚕️</span> Médecin Généraliste
                </h2>
                <div class="text-sm">
                    <p class="text-white font-medium">Dr. ${demande.consultation.generaliste.prenom} ${demande.consultation.generaliste.nom}</p>
                    <p class="text-xs text-slate-400 font-mono mt-0.5">${demande.consultation.generaliste.email}</p>
                    <p class="text-xs text-slate-500 mt-2">Dossier Consultation #${demande.consultation.id}</p>
                </div>
            </div>
        </div>

        <!-- Colonne Droite (2/3) : Question posée (US7) & Réponse du spécialiste (US8) -->
        <div class="lg:col-span-2 space-y-6">

            <!-- Contexte de la Demande & Question posée (US7) -->
            <div class="rounded-2xl bg-slate-800/40 border border-slate-700/50 p-6 md:p-8 backdrop-blur-md">
                <h2 class="text-lg font-bold text-white flex items-center gap-2 mb-4">
                    <span>❓</span> Question Médicale & Contexte Clinique
                </h2>

                <div class="space-y-4">
                    <div class="grid grid-cols-1 md:grid-cols-2 gap-4">
                        <div class="bg-slate-900/60 p-4 rounded-xl border border-slate-800">
                            <span class="text-xs font-semibold text-slate-400 uppercase tracking-wider block mb-1">Motif de consultation</span>
                            <p class="text-sm text-slate-200 font-medium">${demande.consultation.motif}</p>
                        </div>
                        <div class="bg-slate-900/60 p-4 rounded-xl border border-slate-800">
                            <span class="text-xs font-semibold text-slate-400 uppercase tracking-wider block mb-1">Créneau Convenu</span>
                            <p class="text-sm text-indigo-400 font-medium">
                                <c:choose>
                                    <c:when test="${not empty demande.creneau && not empty demande.creneau.heureDebut}">
                                        ${demande.creneau.heureDebut} (30 min)
                                    </c:when>
                                    <c:otherwise>Non spécifié</c:otherwise>
                                </c:choose>
                            </p>
                        </div>
                    </div>

                    <c:if test="${not empty demande.consultation.observations}">
                        <div class="bg-slate-900/60 p-4 rounded-xl border border-slate-800">
                            <span class="text-xs font-semibold text-slate-400 uppercase tracking-wider block mb-1">Observations cliniques du généraliste</span>
                            <p class="text-sm text-slate-300 leading-relaxed">${demande.consultation.observations}</p>
                        </div>
                    </c:if>

                    <div class="p-5 rounded-xl bg-indigo-500/10 border border-indigo-500/30">
                        <span class="text-xs font-bold text-indigo-300 uppercase tracking-wider flex items-center gap-1.5 mb-2">
                            <span>🔍</span> Question du médecin généraliste
                        </span>
                        <p class="text-sm text-white font-medium leading-relaxed bg-slate-900/80 p-4 rounded-lg border border-indigo-500/20">
                            ${demande.question}
                        </p>
                        <span class="text-[11px] text-slate-400 mt-2 block">
                            Envoyée le ${demande.dateDemande}
                        </span>
                    </div>
                </div>
            </div>

            <!-- US8 : Répondre à l'expertise -->
            <div class="rounded-2xl bg-slate-800/40 border border-slate-700/50 p-6 md:p-8 backdrop-blur-md shadow-xl">
                <c:choose>
                    <c:when test="${demande.statut == 'ANNULEE'}">
                        <div class="p-5 rounded-xl bg-rose-500/10 border border-rose-500/30 flex items-start gap-3">
                            <span class="text-2xl">❌</span>
                            <div>
                                <p class="text-rose-300 font-semibold text-sm">Avis annulé</p>
                                <p class="text-slate-300 text-xs mt-1">
                                    Cette demande a été annulée et le créneau est redevenu automatiquement disponible.
                                    La consultation a été rouverte côté généraliste.
                                </p>
                            </div>
                        </div>
                    </c:when>
                    <c:when test="${demande.statut == 'TERMINEE'}">
                        <div class="flex items-center justify-between mb-4 pb-3 border-b border-slate-700/50">
                            <h2 class="text-lg font-bold text-emerald-400 flex items-center gap-2">
                                <span>✅</span> Avis Médical Rendu & Télé-expertise Clôturée
                            </h2>
                            <span class="text-xs text-slate-400">
                                Répondu le : <strong class="text-slate-200">${demande.dateReponse}</strong>
                            </span>
                        </div>

                        <div class="space-y-4">
                            <div class="bg-slate-900/80 p-5 rounded-xl border border-emerald-500/30">
                                <span class="text-xs font-semibold text-emerald-400 uppercase tracking-wider block mb-2">
                                    Avis Médical Spécialisé
                                </span>
                                <p class="text-sm text-slate-100 whitespace-pre-line leading-relaxed">
                                    ${demande.avisMedical}
                                </p>
                            </div>

                            <c:if test="${not empty demande.recommandations}">
                                <div class="bg-slate-900/80 p-5 rounded-xl border border-slate-700">
                                    <span class="text-xs font-semibold text-indigo-400 uppercase tracking-wider block mb-2">
                                        Recommandations & Conduite à Tenir
                                    </span>
                                    <p class="text-sm text-slate-200 whitespace-pre-line leading-relaxed">
                                        ${demande.recommandations}
                                    </p>
                                </div>
                            </c:if>
                        </div>

                        <form action="${pageContext.request.contextPath}/specialiste/annuler-expertise" method="post" class="mt-5 pt-4 border-t border-slate-700/50 flex items-center justify-between gap-3"
                              onsubmit="return confirm('Annuler cet avis ? Le créneau redeviendra automatiquement disponible.');">
                            <input type="hidden" name="_csrf" value="${csrfToken}" />
                            <input type="hidden" name="demandeId" value="${demande.id}" />
                            <span class="text-xs text-slate-400">Une erreur dans l'avis ? Annulez-le pour libérer le créneau.</span>
                            <button type="submit"
                                    class="px-5 py-2.5 rounded-xl bg-rose-600/20 hover:bg-rose-600/30 text-rose-300 border border-rose-500/30 font-semibold text-xs transition flex items-center gap-2 whitespace-nowrap">
                                <span>❌</span> Annuler cet avis
                            </button>
                        </form>
                    </c:when>

                    <c:otherwise>
                        <div class="mb-5">
                            <h2 class="text-lg font-bold text-white flex items-center gap-2">
                                <span>✍️</span> Saisir l'Avis Médical & Clôturer (US8)
                            </h2>
                            <p class="text-xs text-slate-400 mt-1">
                                Renseignez votre avis diagnostique et vos recommandations thérapeutiques. La demande sera marquée comme terminée.
                            </p>
                        </div>

                        <form action="${pageContext.request.contextPath}/specialiste/repondre-expertise" method="post" class="space-y-5">
                            <input type="hidden" name="_csrf" value="${csrfToken}" />
                            <input type="hidden" name="demandeId" value="${demande.id}" />

                            <div>
                                <label class="block text-xs font-semibold text-slate-300 uppercase tracking-wider mb-2">
                                    Avis Médical Spécialisé <span class="text-rose-400">*</span>
                                </label>
                                <textarea name="avisMedical" required rows="5"
                                          placeholder="Exprimez votre diagnostic spécialisé, votre interprétation des symptômes et votre analyse clinique..."
                                          class="w-full px-4 py-3 rounded-xl bg-slate-900 border border-slate-700 text-white text-sm focus:outline-none focus:border-indigo-500 transition leading-relaxed"></textarea>
                            </div>

                            <div>
                                <label class="block text-xs font-semibold text-slate-300 uppercase tracking-wider mb-2">
                                    Recommandations & Traitement Proposé
                                </label>
                                <textarea name="recommandations" rows="4"
                                          placeholder="Précisez la conduite à tenir, les examens complémentaires suggérés ou le protocole de prise en charge..."
                                          class="w-full px-4 py-3 rounded-xl bg-slate-900 border border-slate-700 text-white text-sm focus:outline-none focus:border-indigo-500 transition leading-relaxed"></textarea>
                            </div>

                            <div class="flex items-center justify-between pt-4 border-t border-slate-700/50">
                                <span class="text-xs text-slate-400 flex items-center gap-1.5">
                                    <span>💡</span> L'enregistrement marque définitivement la télé-expertise comme <strong>terminée</strong>.
                                </span>

                                <div class="flex items-center gap-3">
                                    <button type="submit" 
                                            class="px-6 py-3 rounded-xl bg-emerald-600 hover:bg-emerald-500 text-white font-semibold text-sm shadow-lg shadow-emerald-600/30 transition flex items-center gap-2">
                                        <span>✅</span> Transmettre l'avis et terminer
                                    </button>
                                </div>
                            </div>
                        </form>

                        <form action="${pageContext.request.contextPath}/specialiste/annuler-expertise" method="post" class="mt-4 flex items-center justify-end"
                              onsubmit="return confirm('Refuser cette demande ? Le créneau redeviendra automatiquement disponible.');">
                            <input type="hidden" name="_csrf" value="${csrfToken}" />
                            <input type="hidden" name="demandeId" value="${demande.id}" />
                            <button type="submit"
                                    class="px-4 py-2 rounded-xl bg-transparent hover:bg-rose-500/10 text-rose-400/80 hover:text-rose-300 text-xs font-medium transition flex items-center gap-1.5">
                                <span>❌</span> Refuser / Annuler la demande
                            </button>
                        </form>
                    </c:otherwise>
                </c:choose>
            </div>
        </div>
    </div>
</div>

<jsp:include page="../templates/footer.jsp" />