const applicants = [
  { name: 'Jordan Lee', address: '123 Main St', degree: 'Computer Science', level: 'Undergraduate', year: '2026', test: 'SAT', score: '1420', status: 'Pending' },
  { name: 'Maya Patel', address: '45 Oak Ave', degree: 'Data Science', level: 'Graduate', year: '2026', test: 'GRE', score: '320', status: 'Accepted' },
  { name: 'Alex Rivera', address: '8 Park St', degree: 'Information Science', level: 'Undergraduate', year: '2026', test: 'SAT', score: '1300', status: 'Rejected' }
];

const form = document.getElementById('applicant-form');
const search = document.getElementById('search');
const yearSelect = document.getElementById('stats-year');
let editingIndex = null;

function addCell(row, value) {
  const cell = row.insertCell();
  cell.textContent = value;
}

function renderApplicants() {
  const body = document.getElementById('applicants');
  body.replaceChildren();
  const query = search.value.trim().toLowerCase();
  let count = 0;

  applicants.forEach((applicant, index) => {
    const searchable = [applicant.name, applicant.address, applicant.degree].join(' ').toLowerCase();
    if (!searchable.includes(query)) return;
    count++;
    const row = body.insertRow();
    [applicant.name, applicant.address, applicant.degree, applicant.level, applicant.year,
      applicant.test + ' ' + applicant.score, applicant.status].forEach(value => addCell(row, value));
    const button = document.createElement('button');
    button.type = 'button';
    button.textContent = 'Edit';
    button.setAttribute('aria-label', 'Edit ' + applicant.name);
    button.addEventListener('click', () => editApplicant(index));
    row.insertCell().append(button);
  });
  document.getElementById('empty').hidden = count > 0;
}

function renderStatistics() {
  const selectedYear = yearSelect.value;
  const years = [...new Set(applicants.map(applicant => applicant.year))].sort().reverse();
  yearSelect.replaceChildren();
  years.forEach(year => {
    const option = document.createElement('option');
    option.value = year;
    option.textContent = year;
    yearSelect.append(option);
  });
  if (years.includes(selectedYear)) yearSelect.value = selectedYear;

  const records = applicants.filter(applicant => applicant.year === yearSelect.value);
  const accepted = records.filter(applicant => applicant.status === 'Accepted').length;
  const rate = records.length ? (accepted / records.length * 100).toFixed(1) : '0.0';
  document.getElementById('summary').textContent = 'Applications: ' + records.length +
    ' | Accepted: ' + accepted + ' | Admission percentage: ' + rate + '%';

  const averages = document.getElementById('averages');
  averages.replaceChildren();
  ['Undergraduate', 'Graduate'].forEach(level => {
    ['SAT', 'TOEFL', 'GRE'].forEach(test => {
      const scores = records.filter(applicant => applicant.level === level && applicant.test === test)
        .map(applicant => Number(applicant.score));
      if (!scores.length) return;
      const average = scores.reduce((total, score) => total + score, 0) / scores.length;
      const item = document.createElement('li');
      item.textContent = level + ' ' + test + ': ' + average.toFixed(1);
      averages.append(item);
    });
  });
  if (!averages.children.length) {
    const item = document.createElement('li');
    item.textContent = 'No scores for this year.';
    averages.append(item);
  }
}

function render() {
  renderApplicants();
  renderStatistics();
}

function resetForm() {
  editingIndex = null;
  form.reset();
  document.getElementById('form-heading').textContent = 'Add applicant';
  document.getElementById('save').textContent = 'Add applicant';
  document.getElementById('cancel').hidden = true;
}

function editApplicant(index) {
  editingIndex = index;
  const applicant = applicants[index];
  Object.keys(applicant).forEach(key => { form.elements[key].value = applicant[key]; });
  document.getElementById('form-heading').textContent = 'Edit applicant';
  document.getElementById('save').textContent = 'Save changes';
  document.getElementById('cancel').hidden = false;
  form.elements.name.focus();
}

form.addEventListener('submit', event => {
  event.preventDefault();
  const applicant = Object.fromEntries(new FormData(form));
  if (editingIndex === null) applicants.push(applicant);
  else applicants[editingIndex] = applicant;
  resetForm();
  render();
});
document.getElementById('cancel').addEventListener('click', resetForm);
search.addEventListener('input', renderApplicants);
yearSelect.addEventListener('change', renderStatistics);
render();
