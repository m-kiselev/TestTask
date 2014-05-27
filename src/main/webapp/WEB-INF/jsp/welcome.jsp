<!DOCTYPE html>

<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<html lang="en">

<body>
<h3>Welcome page</h3>
<a href="<c:url value="/ping"/>">ping</a><br>
<a href="<c:url value="/date"/>">current date</a>
</body>

</html>