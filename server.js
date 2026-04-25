/**
 * AI Rent Advisor - Backend Server
 * Integrates rental platform logic with GLM AI via Python ai_module
 */

const express = require('express');
const axios = require('axios');
const cors = require('cors');
const dotenv = require('dotenv');
const FinancialRiskEngine = require('./financial_risk_engine');

dotenv.config();

const app = express();

// Middleware
app.use(cors());
app.use(express.json());

// Config
const AI_API_URL = process.env.AI_API_URL || 'http://localhost:5000';
const PORT = process.env.PORT || 3001;

// ============================================================
// DATABASE (In-Memory - Sample Data)
// ============================================================

class RentalPlatformDB {
  constructor() {
    this.users = this.initUsers();
    this.properties = this.initProperties();
    this.leases = this.initLeases();
    this.reviews = this.initReviews();
    this.riskComplaints = this.initRiskComplaints();
    this.trustScores = this.initTrustScores();
    this.deposits = this.initDeposits();
  }

  initUsers() {
    return [
      {
        id: 'user_001',
        name: 'Ahmad Karim',
        email: 'ahmad@email.com',
        role: 'TENANT',
        monthlyIncome: 7000,
        trustScore: 0.85,
        rentalHistory: 3,
        paymentsOnTime: true,
        createdAt: '2024-01-15'
      },
      {
        id: 'user_002',
        name: 'Siti Nurhayati',
        email: 'siti@email.com',
        role: 'TENANT',
        monthlyIncome: 5500,
        trustScore: 0.72,
        rentalHistory: 2,
        paymentsOnTime: true,
        createdAt: '2023-06-20'
      },
      {
        id: 'user_003',
        name: 'Rajesh Kumar',
        email: 'rajesh@email.com',
        role: 'TENANT',
        monthlyIncome: 4200,
        trustScore: 0.45,
        rentalHistory: 1,
        paymentsOnTime: false,
        createdAt: '2024-03-10'
      },
      {
        id: 'landlord_001',
        name: 'Tan Property Investments',
        email: 'tan@realestate.com',
        role: 'LANDLORD',
        propertiesManaged: 12,
        complaintCount: 3,
        trustScore: 0.78,
        createdAt: '2022-01-01'
      },
      {
        id: 'landlord_002',
        name: 'Zainah Hassan',
        email: 'zainah@realestate.com',
        role: 'LANDLORD',
        propertiesManaged: 5,
        complaintCount: 0,
        trustScore: 0.95,
        createdAt: '2023-05-15'
      },
      {
        id: 'landlord_003',
        name: 'Kumar Properties',
        email: 'kumar@realestate.com',
        role: 'LANDLORD',
        propertiesManaged: 8,
        complaintCount: 8,
        trustScore: 0.35,
        createdAt: '2022-10-01'
      }
    ];
  }

  initProperties() {
    const templates = {
      'Cheras': [
        'Vista Harmoni',
        'Ekonomi Flat Kompleks',
        'C180 Lakeview',
        'Cheras Sentral Residensi',
        'Taman Midah Suites',
        'Alam Damai Residences',
        'Bandar Tun Razak Point',
        'Levenue Cheras',
        'Connaught Avenue Homes',
        'Cheras Heights Condominium'
      ],
      'Sentul': [
        'Sentosa Green Heights',
        'Sentul Point Suites',
        'The Fennel Sentul East',
        'M Centura Sentul',
        'Rafflesia Sentul',
        'Sentul Skyline Residence',
        'Bandar Baru Sentul Homes',
        'Sentul West Park',
        'The Maple Sentul',
        'Sentul Arc Apartments'
      ],
      'Bangsar': [
        'Bangsar Luxury Suite',
        'Bangsar Peak',
        'One Menerung',
        'Bangsar Trade Centre Residences',
        'Bangsar Hill Park',
        'The Ara Bangsar',
        'Bangsar South View',
        'Telawi Heights',
        'Serai Bangsar Residences',
        'Bangsar Elite Living'
      ],
      'Petaling Jaya': [
        'Petaling Jaya Heights',
        'Lakepoint Suites',
        'Icon City Serviced Residence',
        'Tropicana Metropark',
        'Kelana Jaya Lakefront',
        'Damansara Intan Residences',
        'Ara Damansara Point',
        'PJ Midtown Residence',
        'Section 13 Urban Homes',
        'Sunway Geo View'
      ]
    };

    let idCounter = 1;
    const properties = [];
    for (const [location, names] of Object.entries(templates)) {
      for (let i = 0; i < names.length; i += 1) {
        const monthlyRent = location === 'Bangsar'
          ? 3200 + (i * 220)
          : location === 'Petaling Jaya'
            ? 2100 + (i * 180)
            : location === 'Sentul'
              ? 1600 + (i * 140)
              : 1500 + (i * 150);
        const marketRent = Math.max(1000, monthlyRent - 120 + (i % 3) * 60);
        properties.push({
          id: `prop_${String(idCounter).padStart(3, '0')}`,
          name: names[i],
          location: location,
          region: location === 'Petaling Jaya' ? 'Selangor' : 'Kuala Lumpur',
          monthly_rent: monthlyRent,
          furnished: i % 2 === 0 ? 'Furnished' : 'Partially Furnished',
          bedrooms: (i % 3) + 1,
          bathrooms: (i % 2) + 1,
          area: 650 + (i * 70),
          facilities: 'Security, Gym, Parking',
          additional_facilities: 'Internet, Lift Access',
          completion_year: 2008 + i,
          prop_name: names[i],
          landlordId: i % 3 === 0 ? 'landlord_003' : i % 2 === 0 ? 'landlord_002' : 'landlord_001',
          averageRating: Math.max(2.2, Math.min(4.9, 3.2 + (i * 0.18))),
          reviewCount: 6 + (i * 3),
          averageMarketRent: marketRent,
          description: `${names[i]} in ${location} with practical amenities`
        });
        idCounter += 1;
      }
    }
    return properties;
  }

  initLeases() {
    return [
      {
        id: 'lease_001',
        propertyId: 'prop_001',
        tenantId: 'user_001',
        landlordId: 'landlord_001',
        startDate: '2024-01-01',
        endDate: '2025-01-01',
        monthlyRent: 2200,
        depositAmount: 6600,
        status: 'ACTIVE'
      },
      {
        id: 'lease_002',
        propertyId: 'prop_002',
        tenantId: 'user_002',
        landlordId: 'landlord_002',
        startDate: '2023-09-15',
        endDate: '2025-09-15',
        monthlyRent: 1800,
        depositAmount: 4500,
        status: 'ACTIVE'
      }
    ];
  }

  initReviews() {
    return [
      {
        id: 'review_001',
        propertyId: 'prop_001',
        tenantId: 'user_001',
        rating: 4,
        title: 'Good location, responsive landlord',
        comment: 'Great amenities but parking is sometimes crowded',
        date: '2024-02-15'
      },
      {
        id: 'review_002',
        propertyId: 'prop_001',
        tenantId: 'user_002',
        rating: 4,
        title: 'Comfortable living',
        comment: 'Clean property, only issue is water pressure',
        date: '2024-01-20'
      },
      {
        id: 'review_003',
        propertyId: 'prop_002',
        tenantId: 'user_002',
        rating: 5,
        title: 'Excellent management team',
        comment: 'Very responsive to maintenance issues',
        date: '2023-12-10'
      },
      {
        id: 'review_004',
        propertyId: 'prop_003',
        tenantId: 'user_003',
        rating: 2,
        title: 'Poor maintenance',
        comment: 'Pipe burst in bathroom, took 2 weeks to fix',
        date: '2024-03-15'
      },
      {
        id: 'review_005',
        propertyId: 'prop_003',
        tenantId: 'user_002',
        rating: 2,
        title: 'Unresponsive landlord',
        comment: 'Complaints ignored for months',
        date: '2024-02-01'
      }
    ];
  }

  initRiskComplaints() {
    return [
      {
        id: 'complaint_001',
        propertyId: 'prop_001',
        property_name: 'Vista Harmoni',
        landlordId: 'landlord_001',
        source: 'forum',
        severity: 'medium',
        severity_score: 5,
        complaint_text: 'Deposit not returned on time',
        complaintText: 'Deposit not returned on time',
        date: '2023-06-15'
      },
      {
        id: 'complaint_002',
        propertyId: 'prop_003',
        property_name: 'Ekonomi Flat Kompleks',
        landlordId: 'landlord_003',
        source: 'review',
        severity: 'high',
        severity_score: 8,
        complaint_text: 'Severe maintenance issues, mold in walls',
        complaintText: 'Severe maintenance issues, mold in walls',
        date: '2024-01-10'
      },
      {
        id: 'complaint_003',
        propertyId: 'prop_003',
        property_name: 'Ekonomi Flat Kompleks',
        landlordId: 'landlord_003',
        source: 'forum',
        severity: 'high',
        severity_score: 8,
        complaint_text: 'Arbitrary rent increases without notice',
        complaintText: 'Arbitrary rent increases without notice',
        date: '2023-11-20'
      },
      {
        id: 'complaint_004',
        propertyId: 'prop_003',
        property_name: 'Ekonomi Flat Kompleks',
        landlordId: 'landlord_003',
        source: 'social_media',
        severity: 'high',
        severity_score: 7,
        complaint_text: 'Poor security, package theft incidents',
        complaintText: 'Poor security, package theft incidents',
        date: '2024-02-05'
      }
    ];
  }

  initTrustScores() {
    return [
      { userId: 'user_001', score: 0.85, factors: { punctuality: 0.9, cleanliness: 0.85, communication: 0.8 } },
      { userId: 'user_002', score: 0.72, factors: { punctuality: 0.75, cleanliness: 0.7, communication: 0.7 } },
      { userId: 'user_003', score: 0.45, factors: { punctuality: 0.3, cleanliness: 0.6, communication: 0.5 } },
      { userId: 'landlord_001', score: 0.78, factors: { responsiveness: 0.8, fairness: 0.75, maintenance: 0.78 } },
      { userId: 'landlord_002', score: 0.95, factors: { responsiveness: 0.95, fairness: 1.0, maintenance: 0.9 } },
      { userId: 'landlord_003', score: 0.35, factors: { responsiveness: 0.2, fairness: 0.4, maintenance: 0.35 } }
    ];
  }

  initDeposits() {
    return [
      { leaseId: 'lease_001', depositAmount: 6600, trustScoreFactor: 0.85, riskAdjustment: 'standard' },
      { leaseId: 'lease_002', depositAmount: 3375, trustScoreFactor: 0.75, riskAdjustment: 'reduced' }
    ];
  }
}

// Initialize Database
const db = new RentalPlatformDB();
const financialEngine = new FinancialRiskEngine(db.riskComplaints);

// ============================================================
// HELPER FUNCTIONS
// ============================================================

function getTrustScore(userId) {
  const trustRecord = db.trustScores.find(t => t.userId === userId);
  return trustRecord ? trustRecord.score : 0.5;
}

function getPropertyComplaints(propertyId) {
  return db.riskComplaints.filter(c => c.propertyId === propertyId);
}

function getPropertyReviews(propertyId) {
  return db.reviews.filter(r => r.propertyId === propertyId);
}

function calculateTenantTrustScore(tenantId) {
  const user = db.users.find(u => u.id === tenantId);
  if (!user) return 0.5;

  let score = 0.5;
  score += user.paymentsOnTime ? 0.25 : -0.15;
  score += (user.rentalHistory / 10) * 0.2;
  score = Math.min(Math.max(score, 0), 1);
  return score;
}

function calculateAdaptiveDeposit(propertyId, tenantId, monthlyRent, trustScore) {
  const baseDeposit = monthlyRent * 2;

  if (trustScore >= 0.8) {
    return {
      amount: Math.round(monthlyRent * 1.5),
      reason: 'Low risk tenant',
      reduction: Math.round(monthlyRent * 0.5)
    };
  } else if (trustScore >= 0.6) {
    return {
      amount: baseDeposit,
      reason: 'Standard deposit',
      reduction: 0
    };
  } else {
    return {
      amount: Math.round(monthlyRent * 2.5),
      reason: 'Higher risk tenant',
      increase: Math.round(monthlyRent * 0.5)
    };
  }
}

function extractComplaintsText(propertyId) {
  const complaints = getPropertyComplaints(propertyId);
  const reviews = getPropertyReviews(propertyId);

  let text = 'Recent feedback:\n';

  complaints.forEach(c => {
    text += `[COMPLAINT] ${c.complaint_text} (${c.source}, severity: ${c.severity})\n`;
  });

  reviews.forEach(r => {
    if (r.rating <= 2) {
      text += `[NEGATIVE REVIEW] "${r.comment}" (${r.date})\n`;
    }
  });

  return text || 'No complaints recorded.';
}

function normalizeText(value) {
  return String(value || '').trim().toLowerCase();
}

function parseMoney(value) {
  if (value === null || value === undefined) return NaN;

  const str = String(value);

  const cleaned = str.replace(/[^0-9.]/g, '');

  if (!cleaned) return NaN;

  return Number(cleaned);
}

function findPropertyMatch({ propertyName, location, area }) {
  const nameNorm = normalizeText(propertyName);
  const locationNorm = normalizeText(location);
  const areaNorm = normalizeText(area);

  // Priority 1: exact name match
  let match = db.properties.find(p => normalizeText(p.name) === nameNorm);
  if (match) return match;

  // Priority 2: partial/fuzzy name match (helps with minor naming differences)
  if (nameNorm) {
    match = db.properties.find(p => normalizeText(p.name).includes(nameNorm) || nameNorm.includes(normalizeText(p.name)));
    if (match) return match;
  }

  // Priority 3: area/location fallback only when name is missing
  if (!nameNorm) {
    match = db.properties.find(p => {
      const pLocation = normalizeText(p.location);
      return (locationNorm && pLocation === locationNorm) || (areaNorm && pLocation === areaNorm);
    });
  }

  return match || null;
}

function buildNegotiationTipsFromInput({
  property,
  askingRent,
  monthlyIncome,
  riskSeverity,
  affordabilityLabel,
  trueCostMonthly,
  hiddenMonthly
}) {
  const ask = Number(askingRent) || property.monthly_rent;
  const income = Number(monthlyIncome) || 0;
  const market = Number(property.averageMarketRent) || ask;
  const realMonthly = Number(trueCostMonthly) || ask;
  const hidden = Number(hiddenMonthly) || Math.max(0, realMonthly - ask);
  const diff = ask - market;
  const target = diff > 0 ? Math.round(market * 0.96) : Math.round(ask * 0.97);
  const ratio = income > 0 ? (realMonthly / income) : 0;

  const opening = diff > 0
    ? `Hi, I like ${property.name}. Listed rent is RM${ask}, but real monthly cost is about RM${realMonthly} (including ~RM${hidden} hidden costs), while nearby market is around RM${market}. Can we discuss RM${target}?`
    : `Hi, I like ${property.name}. Can we discuss a tenant-friendly rate around RM${target} for a longer commitment?`;

  const affordabilityLine = ratio > 0.35 || affordabilityLabel === 'RISKY'
    ? `At real monthly cost RM${realMonthly}, housing is about ${(ratio * 100).toFixed(1)}% of my income, so RM${target} is more sustainable.`
    : `I can pay reliably monthly and would like a fair adjustment to RM${target} for long-term stability.`;

  const riskLine = String(riskSeverity || '').toLowerCase() === 'high'
    ? 'Given reported maintenance/risk concerns, I request a discount or maintenance commitment in writing.'
    : 'I can proceed quickly if we agree on the revised rental and standard maintenance response terms.';

  return [opening, affordabilityLine, riskLine];
}

// ============================================================
// API ROUTES
// ============================================================

app.get('/health', (req, res) => {
  res.json({ status: 'API Running', timestamp: new Date().toISOString() });
});

// ============================================================
// 1. RENTAL VERDICT
// ============================================================
app.post('/api/analyse', async (req, res) => {
  console.log("🔥 /api/analyse HIT", req.body);
  try {
    const { propertyName, location, askingRent, monthlyIncome } = req.body;

    const property = findPropertyMatch({ propertyName, location});

    if (!property) {
      return res.status(404).json({ error: 'Property not found' });
    }

    // 1. Calculate True Cost
    const trueCost = financialEngine.calculateTrueCost(property);

    // 2. Check Affordability
    const affordability = financialEngine.checkAffordability(
      trueCost.firstYearMonthlyAvg,
      monthlyIncome,
      location
    );

    // 3. Get Risk Assessment
    const riskRadar = financialEngine.getRiskRadar(property);

    // 4. Prepare data for AI verdict
    const propertyData = {
      name: property.name,
      location: property.location,
      bedrooms: property.bedrooms,
      bathrooms: property.bathrooms,
      area: property.area,
      furnished: property.furnished,
      askingRent: askingRent,
      monthlyIncome: monthlyIncome,
      averageRating: property.averageRating,
      reviewCount: property.reviewCount
    };

    const marketData = {
      askingRent: askingRent,
      marketAverageRent: property.averageMarketRent,
      rentalGrowth: trueCost.futureProjections,
      location: property.location
    };

    const risks = {
      overallScore: riskRadar.score,
      severity: riskRadar.severity,
      topFlags: riskRadar.allFlags.slice(0, 3)
    };

    const listingText = `${property.name}, ${property.location}, ${property.bedrooms} bed, ${property.bathrooms} bath, ${property.furnished}, RM${askingRent}`;
    const complaintText = extractComplaintsText(property.id);

    // 5. Call AI for all core features
    let verdictData;
    let aiCostData = null;
    let aiRiskData = null;
    let aiNegotiationData = null;
    try {
      console.log("AI verdict OK");
      console.log("AI cost OK");
      console.log("AI risk OK");
      console.log("AI negotiation OK");
      const [verdictResponse, trueCostResponse, riskResponse, negotiationResponse] = await Promise.all([
        axios.post(`${AI_API_URL}/api/verdict`, {
          property_data: propertyData,
          market_data: marketData,
          risks: risks
        }),
        axios.post(`${AI_API_URL}/api/true-cost`, {
          listing_text: listingText
        }),
        axios.post(`${AI_API_URL}/api/risk`, {
          text_data: complaintText
        }),
        axios.post(`${AI_API_URL}/api/negotiation`, {
          price: askingRent,
          market_price: property.averageMarketRent,
          risk: riskRadar.severity
        })
      ]);
      verdictData = verdictResponse.data.data;
      aiCostData = trueCostResponse.data.data;
      aiRiskData = riskResponse.data.data;
      aiNegotiationData = negotiationResponse.data.data;
    } catch (aiError) {
      console.warn('AI integration partially unavailable:', aiError?.message || aiError);
      try {
        const verdictResponse = await axios.post(`${AI_API_URL}/api/verdict`, {
          property_data: propertyData,
          market_data: marketData,
          risks: risks
        });
        verdictData = verdictResponse.data.data;
      } catch (_) {
        verdictData = null;
      }
    }

    const fallbackVerdict = {
      verdict: affordability.label === 'SAFE' ? 'GREAT DEAL' : affordability.label === 'STRETCHED' ? 'ACCEPTABLE' : 'AVOID',
      price_analysis: `Listed at RM${askingRent} vs market average RM${property.averageMarketRent}`,
      risk_analysis: `Risk level: ${riskRadar.severity}`,
      value_analysis: `Affordability: ${affordability.label} (${affordability.ratio})`,
      final_reason: affordability.suggestion
    };

    const resolvedVerdictData = verdictData || fallbackVerdict;

    const aiHiddenCosts = {};
    if (aiCostData && Array.isArray(aiCostData.hidden_costs)) {
      for (const item of aiCostData.hidden_costs) {
        if (!item || !item.type) continue;
        const numeric = parseMoney(item.estimate);
        if (!Number.isNaN(numeric) && numeric > 0) {
          aiHiddenCosts[item.type] = numeric;
        }
      }
    }

    const mergedHiddenCosts = Object.keys(aiHiddenCosts).length > 0 ? aiHiddenCosts : {
      Parking: trueCost.breakdown.estParking,
      Utilities: trueCost.breakdown.estElec,
      'Furnishing Setup': trueCost.breakdown.furnishSurcharge,
      'Internet Setup': trueCost.breakdown.wifiCost,
      'Platform Fees': trueCost.breakdown.platformFees,
      'Maintenance Reserve': trueCost.breakdown.maintenanceProvision
    };

    const hiddenCostTotal = Object.values(mergedHiddenCosts).reduce((sum, value) => {
      const parsed = typeof value === 'number' ? value : parseMoney(value);
      return sum + (Number.isNaN(parsed) ? 0 : parsed);
    }, 0);
    const computedTotal = Number(askingRent) + hiddenCostTotal;
    const aiEstimatedTotal = parseMoney(aiCostData?.estimated_total_monthly);
    const resolvedTrueCostMonthly = !Number.isNaN(aiEstimatedTotal) && aiEstimatedTotal > 0
      ? aiEstimatedTotal
      : (computedTotal > 0 ? computedTotal : trueCost.firstYearMonthlyAvg);

    const negotiationTips = Array.isArray(aiNegotiationData?.strategy) && aiNegotiationData.strategy.length > 0
      ? aiNegotiationData.strategy
      : buildNegotiationTipsFromInput({
        property,
        askingRent,
        monthlyIncome,
        riskSeverity: riskRadar.severity,
        affordabilityLabel: affordability.label,
        trueCostMonthly: resolvedTrueCostMonthly,
        hiddenMonthly: hiddenCostTotal
      });

    const response = {
      verdict: resolvedVerdictData.verdict || 'ACCEPTABLE',
      explanation: resolvedVerdictData.final_reason || 'Balanced option for your needs',
      listedRent: askingRent,
      trueCostMonthly: resolvedTrueCostMonthly,
      hiddenCosts: mergedHiddenCosts,
      riskScore: riskRadar.score,
      riskSummary: aiRiskData?.summary || (riskRadar.severity + ' Risk'),
      negotiationTips: negotiationTips,
      affordability: {
        ratio: affordability.ratio,
        label: affordability.label,
        suggestion: affordability.suggestion
      }
    };

    res.json(response);
  } catch (error) {
    console.error(error);
    res.status(500).json({ error: error.message });
  }
});

// ============================================================
// 2. TRUE ALL-IN COST CALCULATOR
// ============================================================
app.post('/api/true-cost', async (req, res) => {
  try {
    const { propertyId, propertyName } = req.body;

    let property = db.properties.find(p => p.id === propertyId);
    if (!property && propertyName) {
      property = db.properties.find(p => p.name === propertyName);
    }

    if (!property) {
      return res.status(404).json({ error: 'Property not found' });
    }

    const trueCost = financialEngine.calculateTrueCost(property);

    // Call AI for detailed analysis
    let aiCostData;
    try {
      const listingText = `${property.name}, ${property.location}, ${property.bedrooms} bed, ${property.bathrooms} bath, ${property.furnished}, RM${property.monthly_rent}`;
      const aiResponse = await axios.post(`${AI_API_URL}/api/true-cost`, {
        listing_text: listingText
      });
      aiCostData = aiResponse.data.data;
    } catch (aiError) {
      aiCostData = null;
    }

    const hiddenCostMap = {
      Parking: trueCost.breakdown.estParking,
      Electricity: trueCost.breakdown.estElec,
      Furnishing: trueCost.breakdown.furnishSurcharge,
      InternetSetup: trueCost.breakdown.wifiCost,
      PlatformFees: trueCost.breakdown.platformFees,
      Maintenance: trueCost.breakdown.maintenanceProvision,
      DepositImpact: trueCost.breakdown.depositImpact
    };
    const hiddenTotal = Object.values(hiddenCostMap).reduce((sum, v) => sum + (Number(v) || 0), 0);

    const response = {
      baseRent: property.monthly_rent,
      hiddenMonthlyTotal: hiddenTotal,
      trueMonthlyAverage: property.monthly_rent + hiddenTotal,
      hiddenCosts: hiddenCostMap,
      breakdown: [
        { category: 'Base Rent', amount: property.monthly_rent },
        { category: 'Parking', amount: trueCost.breakdown.estParking },
        { category: 'Electricity', amount: trueCost.breakdown.estElec },
        { category: 'Furnishing', amount: trueCost.breakdown.furnishSurcharge },
        { category: 'Internet Setup', amount: trueCost.breakdown.wifiCost },
        { category: 'Platform Fees', amount: trueCost.breakdown.platformFees },
        { category: 'Maintenance', amount: trueCost.breakdown.maintenanceProvision },
        { category: 'First Month Deposit Impact', amount: trueCost.breakdown.depositImpact }
      ],
      futureProjections: trueCost.futureProjections,
      aiInsights: aiCostData || { notes: 'Comprehensive cost breakdown provided' }
    };

    res.json(response);
  } catch (error) {
    console.error(error);
    res.status(500).json({ error: error.message });
  }
});

// ============================================================
// 3. RISK RADAR
// ============================================================
app.post('/api/risk', async (req, res) => {
  try {
    const { propertyId, propertyName } = req.body;

    let property = db.properties.find(p => p.id === propertyId);
    if (!property && propertyName) {
      property = db.properties.find(p => p.name === propertyName);
    }

    if (!property) {
      return res.status(404).json({ error: 'Property not found' });
    }

    const riskRadar = financialEngine.getRiskRadar(property);
    const complaints = getPropertyComplaints(property.id);
    const reviews = getPropertyReviews(property.id);
    const negativeReviews = reviews.filter(r => r.rating <= 2);

    // Extract text for AI analysis
    const complaintText = extractComplaintsText(property.id);

    // Call AI for risk analysis
    let aiRiskData;
    try {
      const aiResponse = await axios.post(`${AI_API_URL}/api/risk`, {
        text_data: complaintText
      });
      aiRiskData = aiResponse.data.data;
    } catch (aiError) {
      aiRiskData = null;
    }

    const landlord = db.users.find(u => u.id === property.landlordId);
    const landlordRisk = {
      complaintCount: landlord ? landlord.complaintCount : 0,
      trustScore: landlord ? landlord.trustScore : 0.5,
      propertiesManaged: landlord ? landlord.propertiesManaged : 0
    };

    const response = {
      riskScore: riskRadar.score,
      severity: riskRadar.severity,
      flags: riskRadar.allFlags,
      complaints: {
        total: complaints.length,
        highSeverity: complaints.filter(c => c.severity === 'high').length,
        recent: complaints.slice(-3)
      },
      reviews: {
        total: reviews.length,
        negativeReviews: negativeReviews.length,
        averageRating: property.averageRating,
        sampleNegative: negativeReviews.slice(0, 2)
      },
      landlordRisk: landlordRisk,
      aiAnalysis: aiRiskData || {
        top_issues: riskRadar.allFlags.map(f => ({
          issue: f.text,
          category: f.type,
          frequency: f.weight > 3 ? 'high' : 'medium'
        })),
        overall_severity: riskRadar.severity,
        summary: `Building has ${riskRadar.severity.toLowerCase()} risk factors`
      }
    };

    res.json(response);
  } catch (error) {
    console.error(error);
    res.status(500).json({ error: error.message });
  }
});

// ============================================================
// 4. NEGOTIATION COACH
// ============================================================
app.post('/api/negotiation', async (req, res) => {
  try {
    const { propertyId, propertyName, monthlyIncome } = req.body;

    let property = db.properties.find(p => p.id === propertyId);
    if (!property && propertyName) {
      property = db.properties.find(p => p.name === propertyName);
    }

    if (!property) {
      return res.status(404).json({ error: 'Property not found' });
    }

    const riskRadar = financialEngine.getRiskRadar(property);
    const trueCost = financialEngine.calculateTrueCost(property);
    const marketDiff = property.monthly_rent - property.averageMarketRent;

    // Call AI for negotiation advice
    let aiNegotiationData;
    try {
      const aiResponse = await axios.post(`${AI_API_URL}/api/negotiation`, {
        price: property.monthly_rent,
        market_price: property.averageMarketRent,
        risk: riskRadar.severity
      });
      aiNegotiationData = aiResponse.data.data;
    } catch (aiError) {
      aiNegotiationData = null;
    }

    const targetPrice = Math.round(property.averageMarketRent * 0.95);
    const landlord = db.users.find(u => u.id === property.landlordId);

    const hiddenMonthly = Math.max(0, trueCost.firstYearMonthlyAvg - property.monthly_rent);
    const negotiationTips = aiNegotiationData?.strategy || buildNegotiationTipsFromInput({
      property,
      askingRent: property.monthly_rent,
      monthlyIncome,
      riskSeverity: riskRadar.severity,
      affordabilityLabel: 'N/A',
      trueCostMonthly: trueCost.firstYearMonthlyAvg,
      hiddenMonthly
    });

    const whatsappMessage = aiNegotiationData?.message ||
      `Hi, I'm very interested in your property at ${property.name}. Listed rent is RM${property.monthly_rent}, but real monthly cost is around RM${Math.round(trueCost.firstYearMonthlyAvg)} including hidden costs. Nearby market is around RM${property.averageMarketRent}. Would you consider RM${targetPrice}? I have stable monthly income of RM${monthlyIncome || 'N/A'}.`;

    const response = {
      currentAskingRent: property.monthly_rent,
      marketAverageRent: property.averageMarketRent,
      suggestedTargetRent: targetPrice,
      savings: property.monthly_rent - targetPrice,
      savingsAnnual: (property.monthly_rent - targetPrice) * 12,
      negotiationReasoning: {
        market: marketDiff > 0 ? `Above market by RM${marketDiff}` : `Below market by RM${Math.abs(marketDiff)}`,
        landlord: `${landlord?.name} - Trust score: ${landlord?.trustScore}`,
        riskProfile: riskRadar.severity
      },
      negotiationTips: negotiationTips,
      readyToSendMessage: whatsappMessage,
      successProbability: Math.max(30, Math.min(90, 70 - (marketDiff * 2)))
    };

    res.json(response);
  } catch (error) {
    console.error(error);
    res.status(500).json({ error: error.message });
  }
});

// ============================================================
// 5. TRUST-BASED DEPOSIT SYSTEM
// ============================================================
app.post('/api/deposit-calculator', async (req, res) => {
  try {
    const { propertyId, tenantId, propertyName, monthlyRent } = req.body;

    let property = db.properties.find(p => p.id === propertyId);
    if (!property && propertyName) {
      property = db.properties.find(p => p.name === propertyName);
    }

    if (!property && monthlyRent) {
      property = { monthly_rent: monthlyRent };
    }

    if (!property) {
      return res.status(404).json({ error: 'Property not found' });
    }

    const rmt = property.monthly_rent || monthlyRent;
    const trustScore = tenantId ? calculateTenantTrustScore(tenantId) : 0.5;
    const tenant = db.users.find(u => u.id === tenantId);

    const adaptiveDeposit = calculateAdaptiveDeposit(property.id, tenantId, rmt, trustScore);

    const response = {
      standardDeposit: rmt * 2,
      adaptiveDeposit: adaptiveDeposit.amount,
      trustScore: trustScore,
      trustScoreFactors: {
        paymentHistory: tenant?.paymentsOnTime ? 'Good' : 'Poor',
        rentalExperience: `${tenant?.rentalHistory || 0} years`,
        communicationRating: 'N/A'
      },
      depositBreakdown: {
        baseAmount: adaptiveDeposit.amount,
        reason: adaptiveDeposit.reason,
        reduction: adaptiveDeposit.reduction || adaptiveDeposit.increase || 0,
        comparison: `Standard: RM${rmt * 2}, You Pay: RM${adaptiveDeposit.amount}`
      },
      benefits: trustScore >= 0.8 ? [
        `Save RM${adaptiveDeposit.reduction} on deposit`,
        'Fast approval process',
        'Priority access to properties'
      ] : trustScore >= 0.6 ? [
        'Standard competitive rates',
        'Flexible payment terms'
      ] : [
        'Available but higher verification required',
        'Consider improving trust score first'
      ],
      trustScoreImpact: {
        currentScore: trustScore,
        nextMilestone: trustScore < 0.8 ? 0.8 : 0.95,
        actionToImprove: 'Maintain on-time payments and cleanliness'
      }
    };

    res.json(response);
  } catch (error) {
    console.error(error);
    res.status(500).json({ error: error.message });
  }
});

// ============================================================
// 6. COMPARISON API (Already required by frontend)
// ============================================================
app.post('/api/compare', async (req, res) => {
  try {
    const { properties, monthlyIncome } = req.body;

    const results = [];

    for (const prop of properties) {
      const property = findPropertyMatch({
        propertyName: prop.propertyName,
        location: prop.location,
        area: prop.area
      });

      if (!property) continue;

      const trueCost = financialEngine.calculateTrueCost(property);
      const riskRadar = financialEngine.getRiskRadar(property);
      const income = Number(prop.monthlyIncome) || Number(monthlyIncome);
      const affordability = financialEngine.checkAffordability(
        trueCost.firstYearMonthlyAvg,
        income,
        property.location
      );

      results.push({
        name: property.name,
        location: property.location,
        monthlyRent: property.monthly_rent,
        verdict: affordability.label === 'SAFE' ? 'GREAT DEAL' : affordability.label === 'STRETCHED' ? 'ACCEPTABLE' : 'AVOID',
        trueCostMonthly: trueCost.firstYearMonthlyAvg,
        riskScore: riskRadar.score,
        affordabilityRatio: affordability.ratio,
        averageRating: property.averageRating,
        reviewCount: property.reviewCount
      });
    }

    res.json({ items: results });
  } catch (error) {
    console.error(error);
    res.status(500).json({ error: error.message });
  }
});

// ============================================================
// 7. DATA ENDPOINTS (For Frontend Reference)
// ============================================================

app.get('/api/properties', (req, res) => {
  res.json(db.properties);
});

app.get('/api/properties/:id', (req, res) => {
  const property = db.properties.find(p => p.id === req.params.id);
  if (!property) return res.status(404).json({ error: 'Not found' });

  const landlord = db.users.find(u => u.id === property.landlordId);
  const reviews = getPropertyReviews(property.id);
  const complaints = getPropertyComplaints(property.id);

  res.json({
    ...property,
    landlord,
    reviews,
    complaints
  });
});

app.get('/api/users/:id', (req, res) => {
  const user = db.users.find(u => u.id === req.params.id);
  if (!user) return res.status(404).json({ error: 'Not found' });

  const trustScore = getTrustScore(req.params.id);
  res.json({ ...user, trustScore });
});

// ============================================================
// START SERVER
// ============================================================

app.listen(PORT, () => {
  console.log(`\n🏠 AI Rent Advisor Backend Running on http://localhost:${PORT}`);
  console.log(`📊 Database initialized with ${db.properties.length} properties`);
  console.log(`👥 Users: ${db.users.length}`);
  console.log(`⚠️  Risk complaints: ${db.riskComplaints.length}\n`);
});

module.exports = app;
