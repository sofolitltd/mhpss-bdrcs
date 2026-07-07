String getTestDisplayName(String testId) {
  const names = {
    'dass21_bn': 'DASS-21 (Bangla)',
    'srq20_bn': 'SRQ-20 (Bangla)',
    'cspt_bn': 'C-SSRS (Bangla)',
  };
  return names[testId] ?? testId;
}
