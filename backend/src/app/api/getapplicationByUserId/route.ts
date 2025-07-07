import { getApplicationsByUserId } from "../../../controllers/applications_controller";
import { NextRequest } from "next/server";

// POST request
export const POST = async (req: NextRequest) => {
  return await getApplicationsByUserId(req);
};
