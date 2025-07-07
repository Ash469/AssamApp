import { createContact, getContacts } from "@/controllers/contact_us";

// POST request 
export const POST = async (req: Request) => {
  return await createContact(req);
};

// GET request 
export const GET = async () => {
  return await getContacts();
};
