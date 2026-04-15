export const RELIGIONS = [
  'Hindu',
  'Muslim',
  'Christian',
  'Sikh',
  'Jain',
  'Buddhist',
  'Parsi',
  'Jewish',
  'Other',
  'No Religion',
];

export const MARITAL_STATUS = [
  'Never Married',
  'Divorced',
  'Widowed',
  'Separated',
];

export const EDUCATION_LEVELS = [
  'High School',
  'Diploma',
  'Bachelors',
  'Masters',
  'Doctorate',
  'Other',
];

export const HEIGHTS = Array.from({ length: 51 }, (_, i) => {
  const totalInches = 48 + i;
  const feet = Math.floor(totalInches / 12);
  const inches = totalInches % 12;
  return `${feet}'${inches}"`;
});

export const INCOME_RANGES = [
  'Below 3 Lakhs',
  '3 - 5 Lakhs',
  '5 - 7 Lakhs',
  '7 - 10 Lakhs',
  '10 - 15 Lakhs',
  '15 - 20 Lakhs',
  '20 - 30 Lakhs',
  '30 - 50 Lakhs',
  '50 Lakhs - 1 Crore',
  'Above 1 Crore',
];

export const SUBSCRIPTION_PLANS = [
  {
    id: 'free',
    name: 'Explore',
    price: 0,
    period: null,
    tagline: 'For discovery',
    features: [
      'Create profile',
      'Unlimited browsing',
      'Send interests',
      'Max 5 connections',
      '15-day timer applies',
    ],
    excluded: ['No chat', 'No contact details'],
  },
  {
    id: 'focus',
    name: 'Focus',
    price: 699,
    period: 'month',
    tagline: 'For serious matchmaking',
    badge: 'Most Popular',
    features: [
      'Chat unlock after mutual connection',
      'View contact details',
      'See who viewed profile',
      'Advanced filters',
      'Connection expiry alerts',
      'Request extension',
      'Serious Intent badge',
    ],
  },
  {
    id: 'commit',
    name: 'Commit',
    price: 1499,
    period: 'month',
    tagline: 'For faster results',
    features: [
      'All Focus features',
      'Priority match ranking',
      'Higher visibility',
      'Verified badge included',
      'Smart match suggestions',
      'Response probability insights',
      'Highlighted profile in search',
    ],
  },
];