#property strict

/// Singleton used to keep track of tests
class TestRunner
{
public:
    static TestRunner* Current;

    int testCount;
    int testFailedCount;
    
    TestRunner()
      : testCount(0), testFailedCount(0)
    {
      Current = GetPointer(this);
    }
    
    ~TestRunner()
    {
        PrintFormat("Test run summary: %u / %u passed", testCount - testFailedCount, testCount);
        if (testFailedCount > 0)
        {
            // fail at runtime by throwing an exception
            Current = NULL;
            Current.testCount++;
        }
    };
};

TestRunner *TestRunner::Current = NULL;

/// Static method to be used in tests
void Assert(bool condition)
{
    TestRunner *t = TestRunner::Current;
    t.testCount++;
    if (!condition) t.testFailedCount++;
};