#include "FinanceEngine.h"

namespace GymOS::Core::Services {

FinanceEngine::FinanceEngine(QObject *parent) : QObject(parent) {}

int64_t FinanceEngine::recordEnrollmentIncome(double amount,
                                              const QString &description,
                                              const QDate &date) {
  return recordEntry(EntryType::EnrollmentIncome, Classification::Income,
                     amount, description, date);
}

int64_t FinanceEngine::recordRenewalIncome(double amount,
                                           const QString &description,
                                           const QDate &date) {
  return recordEntry(EntryType::RenewalIncome, Classification::Income, amount,
                     description, date);
}

int64_t FinanceEngine::recordCustomIncome(double amount,
                                          const QString &description,
                                          const QDate &date) {
  return recordEntry(EntryType::CustomIncome, Classification::Income, amount,
                     description, date);
}

int64_t FinanceEngine::recordCustomExpense(double amount,
                                           const QString &description,
                                           const QDate &date) {
  return recordEntry(EntryType::CustomExpense, Classification::Expense, amount,
                     description, date);
}

FinancialSummary FinanceEngine::getSummary(const QDate &startDate,
                                           const QDate &endDate) const {
  return m_repo.getSummary(startDate, endDate);
}

FinancialSummary FinanceEngine::getTotalSummary() const {
  return m_repo.getTotalSummary();
}

FinancialSummary FinanceEngine::getCurrentMonthSummary() const {
  QDate today = QDate::currentDate();
  QDate firstDay(today.year(), today.month(), 1);
  QDate lastDay = firstDay.addMonths(1).addDays(-1);
  return m_repo.getSummary(firstDay, lastDay);
}

FinancialSummary FinanceEngine::getCurrentYearSummary() const {
  QDate today = QDate::currentDate();
  QDate firstDay(today.year(), 1, 1);
  QDate lastDay(today.year(), 12, 31);
  return m_repo.getSummary(firstDay, lastDay);
}

std::vector<FinancialEntry>
FinanceEngine::getLatestTransactions(int limit) const {
  return m_repo.findLatest(limit);
}

std::vector<MonthlyBreakdown>
FinanceEngine::getMonthlyBreakdown(int months) const {
  QDate endDate = QDate::currentDate();
  QDate startDate = endDate.addMonths(-months + 1);
  startDate = QDate(startDate.year(), startDate.month(), 1);

  return m_repo.getMonthlyBreakdown(startDate, endDate);
}

int64_t FinanceEngine::recordEntry(EntryType type,
                                   Classification classification, double amount,
                                   const QString &description,
                                   const QDate &date) {
  if (amount <= 0) {
    qWarning() << "El monto debe ser positivo";
    return -1;
  }

  FinancialEntry entry;
  entry.entryType = type;
  entry.classification = classification;
  entry.amount = amount;
  entry.description = description;
  entry.entryDate = date;

  int64_t entryId = m_repo.insert(entry);

  if (classification == Classification::Income) {
    emit incomeRecorded(entryId, amount);
  } else {
    emit expenseRecorded(entryId, amount);
  }

  return entryId;
}

} // namespace GymOS::Core::Services
