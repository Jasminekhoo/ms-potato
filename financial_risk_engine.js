/**
 * Financial & Risk Engine
 * Requirements: True Cost, Affordability + Alternatives, Future Simulator, 
 * Risk Radar, and Hidden Truth Highlight.
 */

class FinancialRiskEngine {
    constructor(riskDataset) {
        this.riskDataset = riskDataset; // Mock community complaints

        this.regionalSettings = {
            "Kuala Lumpur": { waterBase: 10, elecFactor: 0.15, baseGrowth: 0.03 },
            "Selangor": { waterBase: 6, elecFactor: 0.12, baseGrowth: 0.02 }
        };

        // Decision Intelligence Mapping: Cheaper alternatives for expensive areas
        this.areaAlternatives = {
            "klcc": "Cheras or Setapak",
            "mont kiara": "Segambut or Sentul",
            "bangsar": "Pantai Dalam or Old Klang Road",
            "subang jaya": "Shah Alam or Putra Heights",
            "petaling jaya": "Kelana Jaya or Ara Damansara"
        };

        this.premiumZones = ["klcc", "bintang", "city centre", "trx", "mont kiara"];
        this.urbanHubs = ["petaling jaya", "subang jaya", "sunway", "damansara", "bangsar"];
    }
5
    parseRent(rentValue) {
        const str = String(rentValue ?? '');
        const cleaned = str.replace(/[^0-9]/g, '');
        return Number(cleaned) || 0;
    }

    /**
     * 1. True Cost Calculator
     * Includes hidden costs and 1st-year monthly average (with 2.5 months deposit)
     */
    calculateTrueCost(row) {
        const advertisedRent = this.parseRent(row.monthly_rent);
        const region = row.region || "Kuala Lumpur";
        const settings = this.regionalSettings[region];

        // Hidden costs: Parking, Furnishing, WiFi, Utilities
        const estParking = (!row.parking || row.parking === 0) ? this.estimateParkingFee(row.location, region) : 0;
        const furnishSurcharge = (row.furnished === "Not Furnished") ? 150 : 0;
        const hasWifi = (row.additional_facilities || "").toLowerCase().includes("internet");
        const wifiCost = hasWifi ? 0 : 100;
        const estElec = Math.round(advertisedRent * settings.elecFactor);

        const totalHiddenMonthly = estParking + furnishSurcharge + estElec + wifiCost + settings.waterBase;

        // First-year monthly average (Rent + Hidden + 2.5 months deposit spread over 12 months)
        const depositImpact = (advertisedRent * 2.5) / 12;
        const firstYearMonthlyAvg = advertisedRent + totalHiddenMonthly + depositImpact;

        return {
            advertisedRent,
            firstYearMonthlyAvg: Math.round(firstYearMonthlyAvg),
            hiddenMonthlyTotal: totalHiddenMonthly,
            breakdown: { estParking, estElec, furnishSurcharge, wifiCost, depositImpact: Math.round(depositImpact) }
        };
    }

    /**
     * 2. Affordability Stress Test
     * Now includes alternative area suggestions if rent is too high
     */
    checkAffordability(trueMonthlyAverage, monthlyIncome, location) {
        const ratio = trueMonthlyAverage / monthlyIncome;
        const loc = (location || "").toLowerCase();

        let result = {
            ratio: (ratio * 100).toFixed(1) + "%",
            label: "SAFE",
            color: "green",
            suggestion: "Great job! This unit fits comfortably within your budget."
        };

        if (ratio > 0.30 && ratio <= 0.45) {
            result.label = "STRETCHED";
            result.color = "orange";
            result.suggestion = "This might be tight. Ensure you have enough for savings.";
        } else if (ratio > 0.45) {
            result.label = "DANGEROUS";
            result.color = "red";

            // Generate Alternative Suggestion
            const alternative = Object.keys(this.areaAlternatives).find(key => loc.includes(key));
            result.suggestion = `Highly expensive. Consider looking in ${this.areaAlternatives[alternative] || "more suburban areas"} for better value.`;
        }

        return result;
    }

    /**
     * 3. Future Cost Simulator (24-month projection)
     */
    projectFutureRent(currentRent, location, region) {
        const loc = location.toLowerCase();
        let growthRate = this.regionalSettings[region].baseGrowth;
        if (this.premiumZones.some(zone => loc.includes(zone))) growthRate = 0.04;

        const year1 = Math.round(currentRent * (1 + growthRate));
        const year2 = Math.round(year1 * (1 + growthRate));

        return [
            { month: 12, rent: year1, label: "Year 1 Renewal" },
            { month: 24, rent: year2, label: "Year 2 Renewal" }
        ];
    }

    /**
     * 4. Risk Radar
     * Returns score (1-10) and array of flags
     */
    getRiskRadar(row) {
        let riskScore = 2;
        let flags = [];
        const facilities = (row.facilities || "").toLowerCase();

        if (!facilities.includes("security")) {
            riskScore += 4;
            flags.push({ type: "Safety", text: "No Gated Security detected.", weight: 4 });
        }
        if (!(row.additional_facilities || "").toLowerCase().includes("lrt") && !(row.additional_facilities || "").toLowerCase().includes("mrt")) {
            riskScore += 2;
            flags.push({ type: "Transit", text: "Low accessibility to public rail.", weight: 2 });
        }

        const forumRecord = this.riskDataset.find(r => row.prop_name && row.prop_name.toLowerCase().includes(r.property_name.toLowerCase()));
        if (forumRecord) {
            riskScore += (forumRecord.severity_score / 2);
            flags.push({ type: "Management", text: forumRecord.complaint_text, weight: forumRecord.severity_score });
        }

        return {
            score: Math.min(Math.round(riskScore), 10),
            allFlags: flags,
            severity: riskScore > 7 ? "High" : riskScore > 4 ? "Medium" : "Low"
        };
    }

    /**
     * 5. Hidden Truth Highlight
     * Isolates the single strongest negative flag for the final summary
     */
    getHiddenTruth(riskData, affordability) {
        // Priority: Dangerous Affordability > High Risk Flags > Stretched Affordability
        if (affordability.label === "DANGEROUS") {
            return "Critical: This rental will consume over 45% of your income.";
        }

        const topRisk = riskData.allFlags.sort((a, b) => b.weight - a.weight)[0];
        if (topRisk && topRisk.weight >= 4) {
            return `Alert: ${topRisk.text}`;
        }

        if (affordability.label === "STRETCHED") {
            return "Note: Rent is slightly high; expect lifestyle adjustments.";
        }

        return "This property shows no major red flags.";
    }

    estimateParkingFee(location, region) {
        const loc = location.toLowerCase();
        if (this.premiumZones.some(zone => loc.includes(zone))) return 300;
        if (this.urbanHubs.some(hub => loc.includes(hub))) return 180;
        return 100;
    }
}

module.exports = FinancialRiskEngine;