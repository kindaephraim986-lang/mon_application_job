const getCandidatePhotoUrl = (profileData = {}, fallback = '') => {
  const candidates = [
    profileData.profile_photo_url,
    profileData.photo_profil_url,
    profileData.photo_url,
    profileData.photo,
    profileData.logo_url,
    fallback,
  ];

  for (const value of candidates) {
    if (typeof value === 'string' && value.trim()) {
      return value.trim();
    }
  }

  return '';
};

const normalizePhotoUrl = (photoUrl = '', baseUrl = '') => {
  if (typeof photoUrl !== 'string') return '';

  const trimmed = photoUrl.trim();
  if (!trimmed) return '';

  if (/^https?:\/\//i.test(trimmed)) {
    return trimmed;
  }

  if (trimmed.startsWith('/')) {
    const normalizedBase = (baseUrl || process.env.APP_BASE_URL || 'http://localhost:3001').replace(/\/$/, '');
    return `${normalizedBase}${trimmed}`;
  }

  return trimmed;
};

module.exports = {
  getCandidatePhotoUrl,
  normalizePhotoUrl,
};
