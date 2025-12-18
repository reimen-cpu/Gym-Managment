cmake_minimum_required(VERSION 3.21)
project(GymOS VERSION 1.0.0 LANGUAGES CXX)

# ============================================================================
# C++ Standard Configuration
# ============================================================================
set(CMAKE_CXX_STANDARD 17)
set(CMAKE_CXX_STANDARD_REQUIRED ON)
set(CMAKE_CXX_EXTENSIONS OFF)

# ============================================================================
# Qt Configuration
# ============================================================================
set(CMAKE_AUTOMOC ON)
set(CMAKE_AUTORCC ON)
set(CMAKE_AUTOUIC ON)

# Find Qt6 packages
find_package(Qt6 REQUIRED COMPONENTS
    Core
    Quick
    QuickControls2
    Sql
    Charts
    Qml
)

qt_standard_project_setup(REQUIRES 6.5)

# ============================================================================
# Source Files
# ============================================================================

set(PROJECT_SOURCES
    # Main
    src/main.cpp
    
    # Core Models
    src/core/models/Member.h
    src/core/models/Member.cpp
    src/core/models/Plan.h
    src/core/models/Plan.cpp
    src/core/models/Subscription.h
    src/core/models/Subscription.cpp
    src/core/models/Payment.h
    src/core/models/Payment.cpp
    src/core/models/FinancialEntry.h
    src/core/models/FinancialEntry.cpp
    
    # Core Services
    src/core/services/SubscriptionManager.h
    src/core/services/SubscriptionManager.cpp
    src/core/services/FinanceEngine.h
    src/core/services/FinanceEngine.cpp
    
    # Infrastructure - Database
    src/infrastructure/database/DatabaseManager.h
    src/infrastructure/database/DatabaseManager.cpp
    
    # Infrastructure - Repositories
    src/infrastructure/repositories/MemberRepository.h
    src/infrastructure/repositories/MemberRepository.cpp
    src/infrastructure/repositories/PlanRepository.h
    src/infrastructure/repositories/PlanRepository.cpp
    src/infrastructure/repositories/SubscriptionRepository.h
    src/infrastructure/repositories/SubscriptionRepository.cpp
    src/infrastructure/repositories/FinancialEntryRepository.h
    src/infrastructure/repositories/FinancialEntryRepository.cpp
    
    # UI Controllers
    src/ui/controllers/DashboardController.h
    src/ui/controllers/DashboardController.cpp
    src/ui/controllers/GymController.h
    src/ui/controllers/GymController.cpp
    
    # Qt Resources
    resources.qrc
)

# ============================================================================
# Create Executable
# ============================================================================
qt_add_executable(GymOS
    ${PROJECT_SOURCES}
)

# ============================================================================
# Target Configuration
# ============================================================================
target_include_directories(GymOS PRIVATE
    "${CMAKE_CURRENT_SOURCE_DIR}/src"
)

target_link_libraries(GymOS PRIVATE
    Qt6::Core
    Qt6::Quick
    Qt6::QuickControls2
    Qt6::Sql
    Qt6::Charts
    Qt6::Qml
)

# ============================================================================
# Windows specific settings
# ============================================================================
if(WIN32)
    set_target_properties(GymOS PROPERTIES
        WIN32_EXECUTABLE TRUE
    )
endif()

# ============================================================================
# Install Configuration
# ============================================================================
install(TARGETS GymOS
    BUNDLE DESTINATION .
    LIBRARY DESTINATION ${CMAKE_INSTALL_LIBDIR}
    RUNTIME DESTINATION ${CMAKE_INSTALL_BINDIR}
)
