/**
 * Financial & Risk Engineer
 * Logic: True Cost, Affordability, Future Simulator, Risk Radar, 
 * Platform Wallet/Payments, and Building Maintenance Risk.
 */

class FinancialRiskEngine {
    constructor(riskDataset) {
        this.riskDataset = riskDataset; // Mock community complaints
        
        this.regionalSettings = {
            "Kuala Lumpur": { waterBase: 10, elecFactor: 0.15, baseGrowth: 0.03 },
            "Selangor": { waterBase: 6, elecFactor: 0.12, baseGrowth: 0.02 }
        };

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

    parseRent(rentString) {
        if (!rentString) return 0;
        return parseInt(rentString.replace(/[^0-9]/g, '')) || 0;
    }

    /**
     * 1. True Cost Calculator
     * Includes Platform Fees & Maintenance Provisions (for the Maintenance feature)
     */
    calculateTrueCost(row) {
        const advertisedRent = this.parseRent(row.monthly_rent);
        const region = row.region || "Kuala Lumpur";
        const settings = this.regionalSettings[region];

        // A. Traditional Hidden Costs
        const estParking = (!row.parking || row.parking === 0) ? this.estimateParkingFee(row.location, region) : 0;
        const furnishSurcharge = (row.furnished === "Not Furnished") ? 150 : 0;
        const hasWifi = (row.additional_facilities || "").toLowerCase().includes("internet");
        const wifiCost = hasWifi ? 0 : 100;
        const estElec = Math.round(advertisedRent * settings.elecFactor);
        
        // B. Building Maintenance Provision (Logic for older buildings)
        const currentYear = new Date().getFullYear();
        const age = row.completion_year ? (currentYear - row.completion_year) : 10;
        const maintenanceProvision = age > 15 ? 50 : (age > 5 ? 20 : 0);

        // C. Platform Transaction Logic (Logic for 'Pay Rental' feature)
        const platformServiceFee = 5.00;
        const fpxFee = 1.00;
        const loyaltyReward = advertisedRent * 0.005; // 0.5% platform cashback

        const totalHiddenMonthly = estParking + furnishSurcharge + estElec + wifiCost + 
                                  settings.waterBase + platformServiceFee + fpxFee + 
                                  maintenanceProvision - loyaltyReward;
        
        const depositImpact = (advertisedRent * 2.5) / 12;
        const firstYearMonthlyAvg = advertisedRent + totalHiddenMonthly + depositImpact;

        return {
            advertisedRent,
            firstYearMonthlyAvg: Math.round(firstYearMonthlyAvg),
            futureProjections: this.projectFutureRent(advertisedRent, row.location, region),
            breakdown: {
                estParking,
                estElec,
                furnishSurcharge,
                wifiCost,
                maintenanceProvision,
                platformFees: platformServiceFee + fpxFee,
                loyaltyCashback: -Math.round(loyaltyReward),
                depositImpact: Math.round(depositImpact)
            }
        };
    }

    /**
     * 2. Affordability Stress Test
     */
    checkAffordability(trueMonthlyAverage, monthlyIncome, location) {
        const ratio = trueMonthlyAverage / monthlyIncome;
        const loc = (location || "").toLowerCase();
        
        let result = { ratio: (ratio * 100).toFixed(1) + "%", label: "SAFE", color: "green", suggestion: "Great job! This unit fits comfortably within your budget." };

        if (ratio > 0.30 && ratio <= 0.45) {
            result = { ratio: (ratio * 100).toFixed(1) + "%", label: "STRETCHED", color: "orange", suggestion: "Consider using our 'Split Pay' wallet feature to manage cash flow." };
        } else if (ratio > 0.45) {
            const alternative = Object.keys(this.areaAlternatives).find(key => loc.includes(key));
            result = { ratio: (ratio * 100).toFixed(1) + "%", label: "DANGEROUS", color: "red", suggestion: `High late-fee risk. Check ${this.areaAlternatives[alternative] || "suburban areas"} for better value.` };
        }
        return result;
    }

    /**
     * 3. Future Cost Simulator
     */
    projectFutureRent(currentRent, location, region) {
        const loc = location.toLowerCase();
        let growthRate = this.regionalSettings[region].baseGrowth;
        if (this.premiumZones.some(zone => loc.includes(zone))) growthRate = 0.04;

        const year1 = Math.round(currentRent * (1 + growthRate));
        const year2 = Math.round(year1 * (1 + growthRate));

        return [{ year: 1, rent: year1 }, { year: 2, rent: year2 }];
    }

    /**
     * 4. Risk Radar (Maintenance & Safety Focus)
     */
    getRiskRadar(row) {
        let riskScore = 2;
        let flags = [];
        const currentYear = new Date().getFullYear();
        const age = row.completion_year ? (currentYear - row.completion_year) : 10;

        // Building Age Risk (Maintenance Feature)
        if (age > 15) {
            riskScore += 3;
            flags.push({ type: "Maintenance", text: `Old Building (${age} yrs): High probability of pipe/wiring issues.`, weight: 3 });
        }

        // Safety Risk
        if (!(row.facilities || "").toLowerCase().includes("security")) {
            riskScore += 4;
            flags.push({ type: "Safety", text: "No Gated Security detected.", weight: 4 });
        }
        
        const forumRecord = this.riskDataset.find(r => row.prop_name && row.prop_name.toLowerCase().includes(r.property_name.toLowerCase()));
        if (forumRecord) {
            riskScore += (forumRecord.severity_score / 2);
            flags.push({ type: "Management", text: forumRecord.complaint_text, weight: forumRecord.severity_score });
        }

        return { score: Math.min(Math.round(riskScore), 10), allFlags: flags, severity: riskScore > 7 ? "High" : riskScore > 4 ? "Medium" : "Low" };
    }

    /**
     * 5. Hidden Truth Highlight
     * Isolates the #1 reason to use the platform or avoid the house
     */
    getHiddenTruth(riskData, affordability, breakdown) {
        if (affordability.label === "DANGEROUS") return "Critical: Rent-to-income ratio exceeds safe platform limits.";
        
        const topRisk = riskData.allFlags.sort((a, b) => b.weight - a.weight)[0];
        if (topRisk && topRisk.weight >= 4) return `Alert: ${topRisk.text}`;

        if (breakdown.maintenanceProvision > 20) return "Note: Higher maintenance budget recommended for this older unit.";

        return `Benefit: Paying via Z.AI earns you ~RM${Math.abs(breakdown.loyaltyCashback)}/mo in rewards.`;
    }

    estimateParkingFee(location, region) {
        const loc = location.toLowerCase();
        if (this.premiumZones.some(zone => loc.includes(zone))) return 300; 
        if (this.urbanHubs.some(hub => loc.includes(hub))) return 180;
        return 100;
    }
}

module.exports = FinancialRiskEngine;
