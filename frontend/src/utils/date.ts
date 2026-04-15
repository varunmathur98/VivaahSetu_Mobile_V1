import { formatDistanceToNow, format, differenceInDays } from 'date-fns';

export const formatTimeAgo = (date: string | Date): string => {
  try {
    return formatDistanceToNow(new Date(date), { addSuffix: true });
  } catch (error) {
    return 'Unknown';
  }
};

export const formatDate = (date: string | Date, formatStr: string = 'MMM dd, yyyy'): string => {
  try {
    return format(new Date(date), formatStr);
  } catch (error) {
    return 'Unknown';
  }
};

export const getDaysRemaining = (expiryDate: string | Date): number => {
  try {
    return differenceInDays(new Date(expiryDate), new Date());
  } catch (error) {
    return 0;
  }
};

export const calculateAge = (birthDate: string | Date): number => {
  const today = new Date();
  const birth = new Date(birthDate);
  let age = today.getFullYear() - birth.getFullYear();
  const monthDiff = today.getMonth() - birth.getMonth();
  
  if (monthDiff < 0 || (monthDiff === 0 && today.getDate() < birth.getDate())) {
    age--;
  }
  
  return age;
};