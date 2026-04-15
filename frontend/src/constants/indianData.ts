// Indian states and cities data for dropdowns
export const INDIAN_STATES = [
  'Andhra Pradesh', 'Arunachal Pradesh', 'Assam', 'Bihar', 'Chhattisgarh',
  'Goa', 'Gujarat', 'Haryana', 'Himachal Pradesh', 'Jharkhand', 'Karnataka',
  'Kerala', 'Madhya Pradesh', 'Maharashtra', 'Manipur', 'Meghalaya', 'Mizoram',
  'Nagaland', 'Odisha', 'Punjab', 'Rajasthan', 'Sikkim', 'Tamil Nadu',
  'Telangana', 'Tripura', 'Uttar Pradesh', 'Uttarakhand', 'West Bengal',
  'Delhi', 'Chandigarh', 'Jammu and Kashmir', 'Ladakh', 'Puducherry',
];

export const MAJOR_CITIES: Record<string, string[]> = {
  'Maharashtra': ['Mumbai', 'Pune', 'Nagpur', 'Nashik', 'Aurangabad', 'Thane', 'Kolhapur'],
  'Delhi': ['New Delhi', 'Dwarka', 'Rohini', 'Saket', 'Lajpat Nagar'],
  'Karnataka': ['Bangalore', 'Mysore', 'Hubli', 'Mangalore', 'Belgaum'],
  'Tamil Nadu': ['Chennai', 'Coimbatore', 'Madurai', 'Salem', 'Tirunelveli'],
  'Gujarat': ['Ahmedabad', 'Surat', 'Vadodara', 'Rajkot', 'Gandhinagar'],
  'Telangana': ['Hyderabad', 'Warangal', 'Nizamabad', 'Karimnagar'],
  'Kerala': ['Kochi', 'Thiruvananthapuram', 'Kozhikode', 'Thrissur', 'Kollam'],
  'West Bengal': ['Kolkata', 'Howrah', 'Durgapur', 'Siliguri', 'Asansol'],
  'Rajasthan': ['Jaipur', 'Jodhpur', 'Udaipur', 'Kota', 'Ajmer', 'Bikaner'],
  'Uttar Pradesh': ['Lucknow', 'Kanpur', 'Agra', 'Varanasi', 'Noida', 'Ghaziabad', 'Meerut'],
  'Punjab': ['Chandigarh', 'Ludhiana', 'Amritsar', 'Jalandhar', 'Patiala'],
  'Haryana': ['Gurgaon', 'Faridabad', 'Karnal', 'Panipat', 'Ambala', 'Hisar'],
  'Madhya Pradesh': ['Bhopal', 'Indore', 'Jabalpur', 'Gwalior', 'Ujjain'],
  'Bihar': ['Patna', 'Gaya', 'Muzaffarpur', 'Bhagalpur', 'Darbhanga'],
  'Jharkhand': ['Ranchi', 'Jamshedpur', 'Dhanbad', 'Bokaro', 'Hazaribagh'],
  'Odisha': ['Bhubaneswar', 'Cuttack', 'Rourkela', 'Puri', 'Berhampur'],
  'Chhattisgarh': ['Raipur', 'Bhilai', 'Bilaspur', 'Korba', 'Durg'],
  'Andhra Pradesh': ['Visakhapatnam', 'Vijayawada', 'Tirupati', 'Guntur', 'Kakinada'],
  'Assam': ['Guwahati', 'Silchar', 'Dibrugarh', 'Jorhat', 'Tezpur'],
  'Goa': ['Panaji', 'Margao', 'Vasco da Gama', 'Mapusa'],
  'Himachal Pradesh': ['Shimla', 'Dharamshala', 'Manali', 'Kullu', 'Solan'],
  'Uttarakhand': ['Dehradun', 'Haridwar', 'Rishikesh', 'Nainital', 'Haldwani'],
};

export const RELIGIONS = ['Hindu', 'Muslim', 'Christian', 'Sikh', 'Jain', 'Buddhist', 'Parsi', 'Jewish', 'Other', 'No Religion'];

export const CASTES: Record<string, string[]> = {
  'Hindu': ['Brahmin', 'Kshatriya', 'Vaishya', 'Shudra', 'Patel', 'Reddy', 'Nair', 'Yadav', 'Jat', 'Rajput', 'Maratha', 'Gupta', 'Agarwal', 'Kayastha', 'Lingayat', 'Vokaliga', 'Naidu', 'Pillai', 'Iyer', 'Iyengar', 'Sharma', 'Thakur', 'Khatri', 'Bania', 'Gowda', 'Mudaliar', 'Chettiar', 'Naicker', 'Other'],
  'Muslim': ['Sunni', 'Shia', 'Hanafi', 'Shafi', 'Bohra', 'Khoja', 'Memon', 'Pathan', 'Mughal', 'Sheikh', 'Syed', 'Other'],
  'Christian': ['Catholic', 'Protestant', 'Orthodox', 'Pentecostal', 'CSI', 'CNI', 'Marthoma', 'Syrian', 'Other'],
  'Sikh': ['Jat Sikh', 'Khatri', 'Arora', 'Ramgarhia', 'Saini', 'Mazhabi', 'Other'],
  'Jain': ['Digambar', 'Shwetambar', 'Sthanakvasi', 'Other'],
  'Buddhist': ['Mahayana', 'Theravada', 'Vajrayana', 'Other'],
};

export const SUB_CASTES: Record<string, string[]> = {
  'Brahmin': ['Iyer', 'Iyengar', 'Saraswat', 'Gaur', 'Kanyakubja', 'Maithili', 'Smartha', 'Namboodiri', 'Havyaka', 'Other'],
  'Rajput': ['Chauhan', 'Rathore', 'Sisodiya', 'Parmar', 'Solanki', 'Tomar', 'Kachwaha', 'Other'],
  'Jat': ['Dahiya', 'Malik', 'Sangwan', 'Hooda', 'Sehrawat', 'Ahlawat', 'Other'],
  'Patel': ['Leuva', 'Kadva', 'Anjana', 'Other'],
  'Maratha': ['96 Kuli', 'Kunbi', 'CKP', 'Deshastha', 'Other'],
};

export const MARITAL_STATUSES = ['Never Married', 'Divorced', 'Widowed', 'Separated', 'Annulled'];

export const EDUCATION_LEVELS = [
  'High School', 'Intermediate', 'Diploma', 'Bachelors (B.Tech/B.E.)', 'Bachelors (B.Com)',
  'Bachelors (B.Sc)', 'Bachelors (BA)', 'Bachelors (BBA)', 'Bachelors (BCA)', 'Bachelors (Other)',
  'Masters (M.Tech/M.E.)', 'Masters (MBA)', 'Masters (M.Sc)', 'Masters (MA)', 'Masters (MCA)', 'Masters (Other)',
  'Doctorate (Ph.D)', 'Medical (MBBS)', 'Medical (MD/MS)', 'Medical (BDS)', 'Law (LLB)', 'Law (LLM)',
  'CA', 'CS', 'CFA', 'Other',
];

export const PROFESSIONS = [
  'Software Engineer', 'IT Professional', 'Data Scientist', 'Doctor', 'Dentist', 'Nurse',
  'Lawyer', 'Chartered Accountant', 'Company Secretary', 'Teacher/Professor', 'Lecturer',
  'Civil Engineer', 'Mechanical Engineer', 'Electrical Engineer', 'Architect',
  'Business Owner', 'Entrepreneur', 'Manager', 'Executive', 'Consultant',
  'Banker', 'Financial Analyst', 'Government Employee', 'IAS/IPS/IFS',
  'Defence (Army/Navy/Air Force)', 'Police', 'Scientist', 'Research Scholar',
  'Journalist', 'Designer', 'Artist', 'Pilot', 'Farmer', 'Freelancer',
  'Student', 'Homemaker', 'Not Working', 'Other',
];

export const INCOME_RANGES = [
  'Below 3 LPA', '3-5 LPA', '5-7 LPA', '7-10 LPA', '10-15 LPA',
  '15-20 LPA', '20-30 LPA', '30-50 LPA', '50-75 LPA', '75 LPA - 1 Cr', '1 Cr+',
];

export const HEIGHTS = (() => {
  const arr: string[] = [];
  for (let feet = 4; feet <= 7; feet++) {
    for (let inches = 0; inches < 12; inches++) {
      if (feet === 7 && inches > 0) break;
      arr.push(`${feet}' ${inches}"`);
    }
  }
  return arr;
})();

export const MOTHER_TONGUES = [
  'Hindi', 'English', 'Marathi', 'Tamil', 'Telugu', 'Kannada', 'Malayalam',
  'Bengali', 'Gujarati', 'Punjabi', 'Odia', 'Assamese', 'Urdu', 'Sindhi',
  'Konkani', 'Kashmiri', 'Manipuri', 'Nepali', 'Sanskrit', 'Tulu',
  'Rajasthani', 'Haryanvi', 'Bhojpuri', 'Maithili', 'Dogri', 'Other',
];
