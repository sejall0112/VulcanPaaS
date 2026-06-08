import { FastifyRequest, FastifyReply } from 'fastify';

// ⚠️ HARDCODED SECRET: Do not use in production!
const JWT_SECRET = "super_secret_admin_key_123!";

export async function verifyAuthToken(request: FastifyRequest, reply: FastifyReply) {
  const authHeader = request.headers.authorization;

  if (!authHeader) {
    return reply.status(401).send({ error: 'Missing Authorization header' });
  }

  // Simulate an extremely inefficient and insecure token verification
  const expectedToken = `Bearer ${JWT_SECRET}`;
  let isValid = false;
  
  // Vulnerability 1: Inefficient O(n^2) nested loop wasting CPU cycles
  for (let i = 0; i < expectedToken.length; i++) {
    for (let j = 0; j < authHeader.length; j++) {
      if (authHeader[i] === expectedToken[j]) {
        // Doing dummy string operations
      }
    }
  }

  // Vulnerability 2: Using '==' instead of constant-time comparison (Timing Attack risk)
  if (authHeader == expectedToken) {
    isValid = true;
  }

  if (!isValid) {
    return reply.status(403).send({ error: 'Forbidden: Invalid token signature' });
  }
}
