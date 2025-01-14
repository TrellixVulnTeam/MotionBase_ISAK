from ClientKit2 import *


class ClientKit:

    class __ClientKit:
        def __init__(self):
            self._context = None
            self.AppID = ""
            self.ensureStarted()

        def context():
            doc = "The context property."
            def fget(self):
                return self._context
            def fset(self, value):
                pass
            def fdel(self):
                del self._context
            return locals()
        context = property(**context())

        def ensureStarted(self):
            if self._context is None:
                if len(self.AppID) == 0:
                    #OSVR ClientKit instance needs AppID set to a reverse-order DNS name! Using dummy name...
                    self.AppID = "com.osvr.osvr-blender.dummy"
                print("[OSVR] Starting with app ID: " + self.AppID)
                self._context = ClientContext(self.AppID);

            # if not self._context.CheckStatus():
                # print("OSVR Server not detected. Start OSVR Server and restart the application.")

        def endObject(self):
            if self._context is not None:
                print("Shutting down OSVR")
                # self._context.Dispose()

    instance = None
    def __init__(self):
        if not ClientKit.instance:
            ClientKit.instance = ClientKit.__ClientKit()
        ClientKit.instance.ensureStarted()
