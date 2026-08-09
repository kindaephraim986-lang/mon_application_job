const test = require('node:test');
const assert = require('node:assert/strict');
const { getCandidatePhotoUrl, normalizePhotoUrl } = require('../utils/profilePhotoUtils');

test('renvoie la photo depuis profile_photo_url quand elle existe', () => {
  const profileData = {
    profile_photo_url: '/uploads/profile-photos/1-photo.jpg',
    photo_profil_url: '/old/photo.jpg',
  };

  assert.equal(getCandidatePhotoUrl(profileData), '/uploads/profile-photos/1-photo.jpg');
});

test('finit par utiliser photo_profil_url si profile_photo_url est vide', () => {
  const profileData = {
    photo_profil_url: '/uploads/profile-photos/legacy.jpg',
  };

  assert.equal(getCandidatePhotoUrl(profileData), '/uploads/profile-photos/legacy.jpg');
});

test('utilise un fallback si aucune colonne de profil n’est renseignée', () => {
  const profileData = {
    profile_photo_url: '',
    photo_profil_url: '',
  };

  assert.equal(getCandidatePhotoUrl(profileData, '/uploads/profile-photos/fallback.jpg'), '/uploads/profile-photos/fallback.jpg');
});

test('retourne une chaîne vide si aucune photo n’est disponible', () => {
  assert.equal(getCandidatePhotoUrl({}), '');
});

test('normalise les URLs de photo en absolues pour l’app mobile/web', () => {
  assert.equal(normalizePhotoUrl('/uploads/profile-photos/abc.jpg'), 'http://localhost:3001/uploads/profile-photos/abc.jpg');
  assert.equal(normalizePhotoUrl('https://example.com/avatar.png'), 'https://example.com/avatar.png');
  assert.equal(normalizePhotoUrl(''), '');
});
